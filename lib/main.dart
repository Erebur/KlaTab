import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klatab/color_schemes.g.dart';
import 'package:klatab/pages/exams.dart';
import 'package:klatab/pages/rooms.dart';
import 'package:klatab/pages/time_table.dart';
import 'package:klatab/requests/timetable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// should be changeable
const _lightColorScheme = lightColorScheme_green;
const _darkColorScheme = darkColorScheme_green;

// should be today
DateTime today = DateTime.now();
late Box hiveBox;

// maybe offline storage
List<List> timetable = [[], [], [], [], [], [], [], [], [], [], []];
List exams = [];
Set rooms = {};

// to be persisted
bool viewExams = true;
bool viewNotes = true;
bool viewRooms = false;
int group = 1;
List wantedRoomsUserdefined = [206, 2052, 2051, 207, 208];
// don't, seriously don't
bool addTermine = false;
String? token;
String? clasz;

// auto generated
bool loggedIn = false;

Future<void> main() async {
  await Hive.initFlutter();
  hiveBox = await Hive.openBox("myBox");
  token = hiveBox.get('token');
  loggedIn = token != null;
  if (!loggedIn) {
    hiveBox.put('viewExams', viewExams);
    hiveBox.put('viewNotes', viewNotes);
    hiveBox.put('viewRooms', viewRooms);
    hiveBox.put('group', group);
    hiveBox.put('wantedRoomsUserdefined', wantedRoomsUserdefined);
  } else {
    viewExams = hiveBox.get("viewExams");
    viewNotes = hiveBox.get("viewNotes");
    viewRooms = hiveBox.get("viewRooms");
    group = hiveBox.get("group");
    wantedRoomsUserdefined = hiveBox.get("wantedRoomsUserdefined");
  }

  setClasz();
  timetable = await loadTimeTable(token, onNetworkError: () {});
  runApp(const MyApp());
}

void setClasz() {
  if (loggedIn) {
    clasz = jsonDecode(
        utf8.decode(base64Url.decode((token ?? "").split(".")[1])))["typValue"];
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        title: 'KlaTab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            colorScheme: lightColorScheme ?? _lightColorScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.transparent),
        darkTheme: ThemeData(
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          colorScheme: darkColorScheme ?? _darkColorScheme,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.transparent,
          tooltipTheme: const TooltipThemeData(
              textStyle: TextStyle(color: Colors.transparent),
              decoration: BoxDecoration(
                color: Colors.transparent,
              )),
        ),
        themeMode: ThemeMode.system,
        home: const MainPage(title: 'KlaTab'),
      );
    });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;
  String username = "";
  String password = "";

  var screens = [
    const PageStundenplan(),
    const PagePruefeungstermine(),
    const PageFreeRooms()
  ];

  void networkError() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text(AppLocalizations.of(context)!.networkError),
              content: Text(AppLocalizations.of(context)!.networkError),
            ));
  }

  @override
  Widget build(BuildContext context) {
    if (!loggedIn) {
      return Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.username,
                        ),
                        autofillHints: const [AutofillHints.email],
                        keyboardType: TextInputType.text,
                        onChanged: (value) =>
                            setState((() => username = value))),
                    TextField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                        ),
                        autofillHints: const [AutofillHints.password],
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (value) =>
                            setState((() => password = value))),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                          onPressed: () async {
                            var post = await http.post(
                                Uri.parse(
                                    "https://ux4.edvschule-plattling.de/klatab-reader/user/login"),
                                headers: {
                                  "content-type": "application/json",
                                  "accept": "application/json",
                                },
                                body: json.encode({
                                  "username": username,
                                  "password": password
                                }));

                            Fluttertoast.showToast(
                                msg: jsonDecode(post.body)["token"] != null
                                    ? AppLocalizations.of(context)!.login_res
                                    : AppLocalizations.of(context)!
                                        .login_res_fail,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                fontSize: 14.0);
                            if (jsonDecode(post.body)["token"] != null) {
                              Hive.box('myBox')
                                  .put('token', jsonDecode(post.body)["token"]);
                              token = jsonDecode(post.body)["token"];
                              loggedIn = true;
                              setClasz();
                              await loadTimeTable(token)
                                  .then((value) => setState(
                                        () {
                                          timetable = value;
                                        },
                                      ));
                              setState(() {});
                            }
                          },
                          label: Text(AppLocalizations.of(context)!.login),
                          icon: const Icon(Icons.login_outlined)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          appBar: AppBar(
              title: Text(widget.title),
              backgroundColor: Theme.of(context).colorScheme.background,
              bottomOpacity: 0,
              centerTitle: true,
              scrolledUnderElevation: 3),
          backgroundColor: Theme.of(context).colorScheme.background);
    }
    return Scaffold(
        primary: true,
        bottomNavigationBar: NavigationBar(
          // backgroundColor: Theme.of(context).colorScheme.background,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          height: 70,
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() {
            this.index = index;
          }),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calendar_view_week_rounded),
              label: AppLocalizations.of(context)!.timetable,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_today),
              label: AppLocalizations.of(context)!.exams,
            )
            // ,
            // NavigationDestination(
            //   icon: const Icon(Icons.room_outlined),
            //   label: AppLocalizations.of(context)!.empty_rooms,
            // )
          ],
        ),
        appBar: AppBar(
          title: Text(
            widget.title,
          ),
          actions: [
            PopupMenuButton(
              onSelected: (item) {},
              color: Theme.of(context).colorScheme.background,
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () {
                    token = null;
                    Hive.box('myBox').delete("token");
                    setState(() {
                      loggedIn = false;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.logout),
                )
              ],
            )
          ],
        ),
        body: screens[index],
        backgroundColor: Theme.of(context).colorScheme.background);
  }
}
