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
import 'package:klatab/pages/timeTable.dart';
import 'package:klatab/requests/timetable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const _lightColorScheme = lightColorScheme_purple;
const _darkColorScheme = darkColorScheme_purple;

String? token;
bool loggedIn = false;
DateTime today = DateTime.parse("2022-07-07");
List<List> timetable = [[], [], [], [], [], [], [], [], [], [], []];

List<Map> exams = [];
bool showExams = true;
bool viewNotes = true;

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox("myBox");
  token = Hive.box('myBox').get('token');
  loggedIn = token != null;
  // String decoded = utf8.decode(
  //     base64Url.decode((token ?? "").split(".")[1])); // username:password
  // print(decoded);
  timetable = await loadTimeTable(token);

  runApp(const MyApp());
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
  bool settings = false;
  String username = "";
  String password = "";

  var screens = [
    const PageStundenplan(),
    const PagePruefeungstermine(),
    const PageFreeRooms()
  ];

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
                              var box = Hive.box('myBox');
                              box.put('token', jsonDecode(post.body)["token"]);
                              token = jsonDecode(post.body)["token"];
                              await loadTimeTable(token)
                                  .then((value) => setState(
                                        () {
                                          timetable = value;
                                        },
                                      ));

                              setState(() {
                                loggedIn = true;
                              });
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
            ),
            NavigationDestination(
              icon: const Icon(Icons.room_outlined),
              label: AppLocalizations.of(context)!.empty_rooms,
            )
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

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
