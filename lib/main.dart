import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:klatab/color_schemes.g.dart';
import 'package:klatab/generated/l10n.dart';
import 'package:klatab/timetable.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';
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

class PageStundenplan extends StatefulWidget {
  const PageStundenplan({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageStundenplanState();
}

class _PageStundenplanState extends State<PageStundenplan> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text(AppLocalizations.of(context)!.settings),
              // actions: <Widget>[
              //   InkWell(
              //     child: Text('OK   '),
              //     onTap: () {
              //       if (_formKey.currentState!.validate()) {
              //         // Do something like updating SharedPreferences or User Settings etc.
              //         Navigator.of(context).pop();
              //       }
              //     },
              //   ),
              // ],
              content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: Text(AppLocalizations.of(context)!.viewNotes),
                        subtitle:
                            Text(AppLocalizations.of(context)!.viewNotesDesc),
                        value: viewNotes,
                        onChanged: (value) =>
                            setState(() => viewNotes = !viewNotes),
                      ),
                      SwitchListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        title:
                            Text(AppLocalizations.of(context)!.highlightExams),
                        value: showExams,
                        onChanged: (value) async {
                          setState(() => showExams = !showExams);
                          timetable = await loadTimeTable(token);
                        },
                      )
                    ],
                  )),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  enableFeedback: false,
                  hoverColor: Theme.of(context).colorScheme.background,
                  splashColor: Theme.of(context).colorScheme.background,
                  highlightColor: Theme.of(context).colorScheme.background,
                  onPressed: () async {
                    today = today.subtract(const Duration(days: 7));
                    await loadTimeTable(token).then((value) => setState(
                          () {
                            timetable = value;
                          },
                        ));
                  },
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  )),
              TextButton(
                  onLongPress: () async {
                    await showInformationDialog(context)
                        .then((value) => setState(() {}));
                  },
                  style: buttonStyleNoReaction(context),
                  onPressed: () async {
                    today = DateTime.now();
                    await loadTimeTable(token).then((value) => setState(
                          () {
                            timetable = value;
                          },
                        ));
                  },
                  child: Text(
                    today
                        .subtract(Duration(days: today.weekday - 1))
                        .toString()
                        .substring(0, 10),
                    style: Theme.of(context).textTheme.bodyLarge,
                  )),
              IconButton(
                  hoverColor: Theme.of(context).colorScheme.background,
                  splashColor: Theme.of(context).colorScheme.background,
                  highlightColor: Theme.of(context).colorScheme.background,
                  onPressed: () async {
                    today = today.add(const Duration(days: 7));
                    await loadTimeTable(token).then((value) => setState(
                          () {
                            timetable = value;
                          },
                        ));
                  },
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    size: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ))
            ],
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DataTable(
                  // columnSpacing: 30,
                  columns: <DataColumn>[
                    DataColumn(label: Text(AppLocalizations.of(context)!.time)),
                  ],
                  rows: [
                    "08:00\n08:45",
                    '08:45\n09:30',
                    '09:45\n10:30',
                    '10:30\n11:15',
                    '11:30\n12:15',
                    '12:15\n13:00',
                    '13:00\n13:45',
                    '13:45\n14:30',
                    '14:45\n15:30',
                    '15:30\n16:15',
                    '16:15\n17:00',
                  ]
                      .map((e) => DataRow(cells: [
                            DataCell(Text(
                              e,
                              style: TextStyle(
                                  color: DateTime.now().isAfter(DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                              int.parse(e
                                                  .split("\n")[0]
                                                  .split(":")[0]),
                                              int.parse(e
                                                  .split("\n")[0]
                                                  .split(":")[1]))) &&
                                          DateTime.now().isBefore(DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                              int.parse(
                                                  e.split("\n")[1].split(":")[0]),
                                              int.parse(e.split("\n")[1].split(":")[1])))
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).textTheme.bodyMedium?.color),
                            ))
                          ]))
                      .toList()),
              Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(10),
                    child: DataTable(
                      // columnSpacing: 30,
                      columns: [
                        AppLocalizations.of(context)!.monday,
                        AppLocalizations.of(context)!.tuesday,
                        AppLocalizations.of(context)!.wednesday,
                        AppLocalizations.of(context)!.thursday,
                        AppLocalizations.of(context)!.friday
                      ]
                          .map((e) => DataColumn(
                              label: Text(e,
                                  style: TextStyle(
                                      color:
                                          DateFormat.EEEE(Platform.localeName)
                                                          .dateSymbols
                                                          .STANDALONEWEEKDAYS[
                                                      today.weekday] ==
                                                  e
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color))))
                          .toList(),
                      rows: timetable
                          .map((day) => DataRow(
                              cells: day
                                  .map((hour) => DataCell(RichText(
                                      softWrap: false,
                                      text: TextSpan(text: "", children: [
                                        TextSpan(
                                            text:
                                                "${hour["raum"]} ${hour["raum2"] != "" ? ' -  ${hour["raum2"]}' : hour["lehrer"]}\n",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                        TextSpan(
                                            text:
                                                "${hour["fach"]} ${hour["fach2"] != "" && hour["fach2"] != hour["fach"] ? ' |  ${hour["fach2"]}' : ""}${viewNotes && hour["notiz"] != "" ? '\n${hour["notiz"]}' : ''}",
                                            style: TextStyle(
                                                color: hour["istVertretung"] ==
                                                        true
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : hour["isExam"] &&
                                                            showExams
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .error
                                                        : Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color))
                                      ]))))
                                  .toList()))
                          .toList(),
                    )),
              ),
            ],
          ),
        ));
  }

  ButtonStyle buttonStyleNoReaction(BuildContext context) {
    return ButtonStyle(
      overlayColor: MaterialStateProperty.resolveWith(
          (states) => Theme.of(context).colorScheme.background),
      // backgroundColor: MaterialStateProperty.resolveWith(
      //     (states) => Theme.of(context).colorScheme.background)
    );
  }
}

class PagePruefeungstermine extends StatefulWidget {
  const PagePruefeungstermine({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PagePruefeungstermineState();
}

class _PagePruefeungstermineState extends State<PagePruefeungstermine> {
  bool weeklyOverview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {
            setState(() {
              weeklyOverview = !weeklyOverview;
            });
          },
          child: Text(
            weeklyOverview
                ? AppLocalizations.of(context)!.calendar
                : AppLocalizations.of(context)!.compact,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        // toolbarHeight:
        //     (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 10) + 10,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Stack(
            children: [
              Visibility(
                maintainState: true,
                visible: weeklyOverview,
                child: Timetable(
                    controller:
                        TimetableController(start: today, cellHeight: 40),
                    itemBuilder: (item) => Container(
                          decoration: BoxDecoration(
                            color: (item.data as Map)["art"] == "SA"
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: Center(
                              child: Text(
                                "${(item.data as Map)["fach"]} ${(item.data as Map)["art"]}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                          ),
                        ),
                    items: exams
                        .map((item) => TimetableItem(item["start"], item["end"],
                            data: item))
                        .toList()),
              ),
              Visibility(
                  maintainState: true,
                  visible: !weeklyOverview,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: exams
                          .map(
                            (item) => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Card(
                                    child: SizedBox(
                                      height: 130,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                  width: 70,
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          item["fach"],
                                                          style: TextStyle(
                                                              color: item["art"] ==
                                                                      "SA"
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.color),
                                                        ),
                                                        Text(
                                                          item["art"],
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                        )
                                                      ])),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(((item["start"]
                                                                as DateTime)
                                                            .toLocal()
                                                            .toString())
                                                        .substring(0, 10)),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                          "${((item["start"] as DateTime).toLocal().toString()).substring(11, 16)}-${((item["end"] as DateTime).toLocal().toString()).substring(11, 16)}"),
                                                    )
                                                  ]),
                                              SizedBox(
                                                width: 80,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          "${item["start_hour"]} - ${item["end_hour"]}"),
                                                      Text(
                                                          "${item["raum"]} - ${item["lehrer"]}")
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  launchUrl(
                                                      Uri.parse(item["link"]),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_month),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .add,
                                                      style: TextStyle(
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.fontSize),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ]),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ))
            ],
          )),
    );
  }
}

class PageFreeRooms extends StatefulWidget {
  const PageFreeRooms({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageFreeRoomsState();
}

class _PageFreeRoomsState extends State<PageFreeRooms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            TextButton.icon(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    surfaceTintColor: Colors.white),
                onPressed: () {},
                icon: const Icon(Icons.notes_outlined),
                label: const Text("toggle Notes"))
          ],
        ),
      ),
    );
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
