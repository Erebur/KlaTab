import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klatab/color_schemes.g.dart';
import 'package:klatab/exams.dart';
import 'package:klatab/timetable.dart';

const _lightColorScheme = lightColorScheme_green;
const _darkColorScheme = darkColorScheme_green;

String? token;
bool loggedIn = false;
List<List> timetable = [[], [], [], [], [], [], [], [], [], [], []];
List exams = [];

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox("myBox");
  token = Hive.box('myBox').get('token');
  loggedIn = token != null;
  timetable = await loadTimeTable(token);
  exams = await loadExams();

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
        title: 'KlaTab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: lightColorScheme ?? _lightColorScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.transparent),
        darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? _darkColorScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.transparent),
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

  var screens = [const PageStundenplan(), const Page_Pruefeungstermine()];

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
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        autofillHints: const [AutofillHints.username],
                        keyboardType: TextInputType.text,
                        onChanged: (value) =>
                            setState((() => username = value))),
                    TextField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
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
                                    ? "Logged in"
                                    : "Error logging in",
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
                              await loadExams().then((value) => setState(
                                    () {
                                      exams = value;
                                    },
                                  ));
                              setState(() {
                                loggedIn = true;
                              });
                            }
                          },
                          label: const Text('Login'),
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
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() {
            this.index = index;
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_view_week_rounded),
              label: "Stundenplan",
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today),
              label: "Schulaufgaben",
            )
          ],
        ),
        appBar: AppBar(
          title: Text(widget.title),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.up,
        children: [
          DataTable(
            // columnSpacing: 30,
            columns: const <DataColumn>[
              DataColumn(label: Text("Zeit")),
            ],
            rows: const [
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('08:00\n08:45')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('08:45\n09:30')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('09:45\n10:30')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('10:30\n11:15')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('11:30\n12:15')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('12:15\n13:00')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('13:00\n13:45')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('13:45\n14:30')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('14:45\n15:30')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('15:30\n16:15')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('16:15\n17:00')),
                ],
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                child: DataTable(
                  // columnSpacing: 30,
                  columns: const <DataColumn>[
                    DataColumn(label: Text("Montag")),
                    DataColumn(label: Text("Dienstag")),
                    DataColumn(label: Text("Mittwoch")),
                    DataColumn(label: Text("Donerstag")),
                    DataColumn(label: Text("Freitag")),
                  ],
                  rows: timetable
                      .map((day) => DataRow(
                          cells: day
                              .map((hour) => DataCell(RichText(
                                  softWrap: false,
                                  text: TextSpan(text: "", children: [
                                    TextSpan(
                                        text:
                                            "${hour["raum"]} ${hour["raum2"] != "" ? ' -\t ${hour["raum2"]}' : hour["lehrer"]}\n",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    TextSpan(
                                        text:
                                            "${hour["fach"]} ${hour["fach2"] != "" && hour["fach2"] != hour["fach"] ? ' |\t ${hour["fach2"]}' : ""}${hour["notiz"] != "" ? '\n${hour["notiz"]}' : ''}",
                                        style: TextStyle(
                                            color:
                                                hour["istVertretung"] == true &&
                                                        hour["notiz"] != ""
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
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
}

class Page_Pruefeungstermine extends StatefulWidget {
  const Page_Pruefeungstermine({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Page_PruefeungstermineState();
}

class _Page_PruefeungstermineState extends State<Page_Pruefeungstermine> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: exams.map((e) => Text("$e\n")).toList())),
      );
}
