import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:klatab/color_schemes.g.dart';
import 'package:klatab/pages/exams.dart';
import 'package:klatab/pages/time_table.dart';
import 'package:klatab/requests/timetable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_io/io.dart';

var _lightColorScheme = lightColorScheme_default;
var _darkColorScheme = darkColorScheme_default;

Map<String, ColorScheme> lightColorSchemes = {
  "default": lightColorScheme_default,
  "green": lightColorScheme_green,
  "purple": lightColorScheme_purple,
  "turquoise": lightColorScheme_turquoise,
  "yellow": lightColorScheme_yellow,
  "blue": lightColorScheme_blue,
  "pink": lightColorScheme_pink
};
Map<String, ColorScheme> darkColorSchemes = {
  "default": darkColorScheme_default,
  "green": darkColorScheme_green,
  "purple": darkColorScheme_purple,
  "turquoise": darkColorScheme_turquoise,
  "yellow": darkColorScheme_yellow,
  "blue": darkColorScheme_blue,
  "pink": darkColorScheme_pink
};

Function? restart;

// should be today
DateTime wantedWeek = DateTime.now().weekday > 5
    ? DateTime.now().add(Duration(days: 7 - (DateTime.now().weekday - 1)))
    : DateTime.now();
DateTime today = wantedWeek;
late Box hiveBox;
String title = "KlaTab";
// maybe offline storage
List<List> timetable = [[], [], [], [], [], [], [], [], [], [], []];
List exams = [];
Set rooms = {};

// persisted
bool viewExams = true;
bool viewNotes = true;
bool viewRooms = false;
bool weeklyOverview = false;
bool addTermine = true;
String theme = "default";
int group = 1;
bool onlyGroups = false;
List wantedRoomsUserdefined = [206, 2052, 2051, 207, 208];

String? token;
String? grade;

// auto generated
bool loggedIn = false;

Future<void> main() async {
  await Hive.initFlutter();
  hiveBox = await Hive.openBox("myBox");
  token = hiveBox.get('token');
  loggedIn = token != null;

  viewExams = hiveHelper("viewExams", viewExams);
  viewNotes = hiveHelper("viewNotes", viewNotes);
  viewRooms = hiveHelper("viewRooms", viewRooms);
  addTermine = hiveHelper("addTermine", addTermine);

  weeklyOverview = hiveHelper("weeklyOverview", weeklyOverview);
  group = hiveHelper("group", group);
  wantedRoomsUserdefined =
      hiveHelper("wantedRoomsUserdefined", wantedRoomsUserdefined);
  onlyGroups = hiveHelper("onlyGroups", onlyGroups);
  theme = hiveHelper("ColorScheme", theme);

  _darkColorScheme = darkColorSchemes[theme]!;
  _lightColorScheme = lightColorSchemes[theme]!;
  // initializing timetable Grid
  timetable = await loadTimeTable(token, onNetworkError: () {});
  runApp(const MyApp());
}

hiveHelper(String s, value) {
  if (hiveBox.containsKey(s)) {
    return hiveBox.get(s);
  } else {
    hiveBox.put(s, value);
    return value;
  }
}

void setGrade() {
  try {
    var tmp = jsonDecode(utf8.decode(
        base64Url.decode(base64.normalize((token ?? "").split(".")[1]))));
    grade = tmp["typValue"];
    hiveBox.put('grade', grade);
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void restart({Function()? fn}) {
    setState(() => fn?.call());
  }

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
        themeMode: ThemeMode.system,
        home: MainPage(title: 'KlaTab', restart: restart),
        theme: ThemeData(
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          colorScheme: lightColorScheme ?? _lightColorScheme,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.transparent,
          tooltipTheme: TooltipThemeData(
              waitDuration: const Duration(seconds: 2),
              textStyle: TextStyle(
                  color: (darkColorScheme ?? _darkColorScheme).onBackground),
              decoration: BoxDecoration(
                color: (darkColorScheme ?? _darkColorScheme).background,
              )),
          dialogBackgroundColor:
              (lightColorScheme ?? _lightColorScheme).background,
        ),
        darkTheme: ThemeData(
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            colorScheme: darkColorScheme ?? _darkColorScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.transparent,
            tooltipTheme: TooltipThemeData(
                waitDuration: const Duration(seconds: 2),
                textStyle: TextStyle(
                    color: (darkColorScheme ?? _darkColorScheme).onBackground),
                decoration: BoxDecoration(
                  color: (darkColorScheme ?? _darkColorScheme).background,
                )),
            dialogBackgroundColor:
                (darkColorScheme ?? _darkColorScheme).background),
      );
    });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title, required this.restart})
      : super(key: key);
  final String title;
  final void Function({Function()? fn}) restart;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int index = 0;
  String username = "";
  String password = "";

  var screens = [
    const PageTimetable(),
    const PageExams(),
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
    restart = widget.restart;
    if (!loggedIn) {
      return loginPage();
    } else if (MediaQuery.of(context).size < const Size(200, 200)) {
      return wearOSPage();
    } else {
      return mainPage();
    }
  }

// testing
  Scaffold wearOSPage() => Scaffold(
        primary: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Column(
          children: [
            Text(DateTime.now().toString().substring(11, 16)),
            Text(DateFormat.EEEE(Platform.localeName)
                .dateSymbols
                .WEEKDAYS[today.weekday == 7 ? 0 : today.weekday]),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: const [
                                Text("Fach"),
                                Text("Lehrer"),
                                Text("Raum"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Java",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                Text(
                                  "Ro",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                Text(
                                  "207",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Scaffold mainPage() => Scaffold(
      primary: true,
      bottomNavigationBar: NavigationBar(
        // backgroundColor: Theme.of(context).,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 70,
        selectedIndex: index,
        onDestinationSelected: (index) => setState(() {
          this.index = index;
        }),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.view_timeline_outlined),
            selectedIcon: const Icon(Icons.view_timeline_rounded),
            label: AppLocalizations.of(context)!.timetable,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today_rounded),
            label: AppLocalizations.of(context)!.exams,
          )
        ],
      ),
      body: screens[index],
      backgroundColor: Theme.of(context).colorScheme.background);

  Scaffold loginPage() => Scaffold(
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
                    onChanged: (value) => setState((() => username = value))),
                TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                    ),
                    autofillHints: const [AutofillHints.password],
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    onSubmitted: (value) async {
                      await login();
                    },
                    onChanged: (value) => setState((() => password = value))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                      onPressed: () async {
                        await login();
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

  Future<void> login() async {
    var post;
    bool? result;
    try {
      post = await http.post(
          Uri.parse(
              "https://ux4.edvschule-plattling.de/klatab-reader/user/login"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
          },
          body: json.encode({"username": username, "password": password}));
      result = jsonDecode(post.body);
    } catch (e) {}
    var tmp = jsonDecode(post.body);
    Fluttertoast.showToast(
        msg: (result != null && result) || result == null
            ? AppLocalizations.of(context)!.login_res
            : AppLocalizations.of(context)!.login_res_fail,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 14.0);

    if (tmp["token"] != null) {
      setState(() {
        token = tmp["token"];
        loggedIn = true;
        setGrade();
      });
      Hive.box('myBox').put('token', tmp["token"]);
    }
  }
}

Future<void> settings(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: Text(AppLocalizations.of(context)!.settings),
            content: Form(
                child: Column(
              children: [
                SwitchListTile(
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(AppLocalizations.of(context)!.viewNotes),
                  subtitle: Text(AppLocalizations.of(context)!.viewNotesDesc),
                  value: viewNotes,
                  onChanged: (value) {
                    setState(() => viewNotes = !viewNotes);
                    hiveBox.put('viewNotes', viewNotes);
                  },
                ),
                SwitchListTile(
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(AppLocalizations.of(context)!.highlightExams),
                  subtitle:
                      Text(AppLocalizations.of(context)!.highlightExamsDesc),
                  value: Hive.box("myBox").get("viewExams"),
                  onChanged: (value) {
                    setState(() => viewExams = !viewExams);
                    hiveBox.put('viewExams', viewExams);
                  },
                ),
                SwitchListTile(
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(AppLocalizations.of(context)!.viewRooms),
                  subtitle: Text(AppLocalizations.of(context)!.viewRoomsDesc),
                  value: viewRooms,
                  onChanged: (value) {
                    setState(() => viewRooms = !viewRooms);
                    hiveBox.put('viewRooms', viewRooms);
                  },
                ),
                SwitchListTile(
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(AppLocalizations.of(context)!.mixEvents),
                  subtitle: Text(AppLocalizations.of(context)!.mixEventsDesc),
                  value: addTermine,
                  onChanged: (value) {
                    setState(() => addTermine = !addTermine);
                    hiveBox.put('addTermine', addTermine);
                  },
                ),
                SwitchListTile(
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(AppLocalizations.of(context)!.onlyGroups),
                  subtitle: Text(AppLocalizations.of(context)!.onlyGroupsDesc),
                  value: onlyGroups,
                  onChanged: (value) {
                    setState(() => onlyGroups = !onlyGroups);
                    hiveBox.put('onlyGroups', onlyGroups);
                  },
                ),
                ExpansionTile(
                    title: Text(AppLocalizations.of(context)!.groupInputs),
                    children: [
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.wantedRooms),
                        subtitle: TextField(
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                              text: wantedRoomsUserdefined
                                  .toString()
                                  .replaceAll("[", "")
                                  .replaceAll("]", "")
                                  .replaceAll(" ", "")),
                          onSubmitted: (value) async {
                            setState(() => wantedRoomsUserdefined = value
                                .split(",")
                                .map((e) => int.parse(e))
                                .toList());
                            hiveBox.put('wantedRoomsUserdefined',
                                wantedRoomsUserdefined);
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.group),
                        subtitle: TextField(
                          keyboardType: TextInputType.number,
                          controller:
                              TextEditingController(text: group.toString()),
                          onSubmitted: (value) {
                            setState(() => group = int.parse(value));
                            hiveBox.put('group', group);
                          },
                        ),
                      ),
                      ListTile(
                          title: Text(AppLocalizations.of(context)!.clasz),
                          subtitle: TextField(
                              controller: TextEditingController(text: grade),
                              onSubmitted: (value) {
                                setState(() {
                                  grade = value;
                                });
                                hiveBox.put('grade', grade);
                              })),
                      ListTile(
                        title: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: theme.substring(0, 1).toUpperCase() +
                                  theme.substring(1)),
                          mouseCursor: MaterialStateMouseCursor.clickable,
                          cursorColor:
                              Theme.of(context).textTheme.bodyLarge?.color,
                          decoration: InputDecoration(
                            label: Text(AppLocalizations.of(context)!.theme),
                            labelStyle: Theme.of(context).textTheme.labelLarge,
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            listDialog(context, setState, onTap: (e) {
                              theme = e;
                              _darkColorScheme = darkColorSchemes[theme]!;
                              _lightColorScheme = lightColorSchemes[theme]!;
                              hiveBox.put('ColorScheme', theme);
                              setState((() {}));
                              restart?.call();
                              Navigator.of(context).pop(e);
                            });
                          },
                        ),
                      )
                    ])
              ],
            )),
          );
        });
      });
}

void listDialog(BuildContext context, StateSetter setState,
    {Function(String e)? onTap}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        scrollable: true,
        content: Form(
          child: Column(
              children: darkColorSchemes.keys
                  .map((e) => ListTile(
                        title: TextButton(
                            style: ButtonStyle(
                              alignment: Alignment.centerLeft,
                              overlayColor: MaterialStateProperty.resolveWith(
                                  (states) =>
                                      Theme.of(context).colorScheme.background),
                              // backgroundColor: MaterialStateProperty.resolveWith(
                              //     (states) => Theme.of(context).colorScheme.background)
                            ),
                            onPressed: () {
                              onTap?.call(e);
                            },
                            child: Text(
                              e.substring(0, 1).toUpperCase() + e.substring(1),
                              style: TextStyle(
                                  color: darkColorSchemes[e]?.primary),
                            )),
                      ))
                  .toList()),
        ),
      );
    },
  );
}

AppBar titleBar(BuildContext context, setState) {
  return AppBar(
    title: Text(
      title,
    ),
    actions: [
      PopupMenuButton(
        onSelected: (item) {},
        color: Theme.of(context).colorScheme.background,
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () {
              token = null;
              hiveBox.delete("token");
              hiveBox.delete('group');
              loggedIn = false;
              restart!();
            },
            child: Text(AppLocalizations.of(context)!.logout),
          ),
          PopupMenuItem(
              child: Text(AppLocalizations.of(context)!.settings),
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  settings(context).then((value) => setState(
                        () {},
                      ));
                });
              })
        ],
      )
    ],
  );
}
