import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:klatab/requests/timetable.dart';
import 'package:universal_io/io.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:klatab/main.dart';

class PageTimetable extends StatefulWidget {
  const PageTimetable({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageTimetableState();
}

class _PageTimetableState extends State<PageTimetable> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              scrollable: true,
              title: Text(AppLocalizations.of(context)!.settings),
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
                        onChanged: (value) {
                          setState(() => viewNotes = !viewNotes);
                          hiveBox.put('viewNotes', viewNotes);
                        },
                      ),
                      SwitchListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        title:
                            Text(AppLocalizations.of(context)!.highlightExams),
                        subtitle: Text(
                            AppLocalizations.of(context)!.highlightExamsDesc),
                        value: Hive.box("myBox").get("viewExams"),
                        onChanged: (value) {
                          setState(() => viewExams = !viewExams);
                          hiveBox.put('viewExams', viewExams);
                        },
                      ),
                      SwitchListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: Text(AppLocalizations.of(context)!.viewRooms),
                        subtitle:
                            Text(AppLocalizations.of(context)!.viewRoomsDesc),
                        value: viewRooms,
                        onChanged: (value) {
                          setState(() => viewRooms = !viewRooms);
                          hiveBox.put('viewRooms', viewRooms);
                        },
                      ),
                      ExpansionTile(
                          title:
                              Text(AppLocalizations.of(context)!.groupInputs),
                          children: [
                            ListTile(
                              title: Text(
                                  AppLocalizations.of(context)!.wantedRooms),
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
                                controller: TextEditingController(
                                    text: group.toString()),
                                onSubmitted: (value) {
                                  setState(() => group = int.parse(value));
                                  hiveBox.put('group', group);
                                },
                              ),
                            ),
                            ListTile(
                                title:
                                    Text(AppLocalizations.of(context)!.clasz),
                                subtitle: TextField(
                                    controller:
                                        TextEditingController(text: grade),
                                    onSubmitted: (value) {
                                      setState(() {
                                        grade = value;
                                      });
                                      hiveBox.put('grade', grade);
                                    })),
                            ListTile(
                                title: Text("Token"),
                                subtitle: TextField(
                                    controller:
                                        TextEditingController(text: token),
                                    ))
                          ])
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
                    wantedWeek = wantedWeek.subtract(const Duration(days: 7));
                    setState(() {});
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
                    wantedWeek = today;
                    setState(() {});
                  },
                  child: Text(
                    wantedWeek
                        .subtract(Duration(days: wantedWeek.weekday - 1))
                        .toString()
                        .substring(0, 10),
                    style: Theme.of(context).textTheme.bodyLarge,
                  )),
              IconButton(
                  hoverColor: Theme.of(context).colorScheme.background,
                  splashColor: Theme.of(context).colorScheme.background,
                  highlightColor: Theme.of(context).colorScheme.background,
                  onPressed: () async {
                    wantedWeek = wantedWeek.add(const Duration(days: 7));
                    setState(() {});
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
                    child: FutureBuilder(
                      future: loadTimeTable(token),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          timetable = (snapshot.data as List<List>);
                        }
                        return DataTable(
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
                                          color: DateFormat.EEEE(Platform
                                                              .localeName)
                                                          .dateSymbols
                                                          .STANDALONEWEEKDAYS[
                                                      wantedWeek.weekday == 7
                                                          ? 0
                                                          : wantedWeek
                                                              .weekday] ==
                                                  e
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color))))
                              .toList(),
                          rows: (snapshot.hasData
                                  ? (snapshot.data as List<List>)
                                  : timetable)
                              .map((day) => DataRow(
                                  cells: day
                                      .map((hour) => DataCell(RichText(
                                          softWrap: false,
                                          text: TextSpan(text: "", children: [
                                            TextSpan(
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                StatefulBuilder(
                                                                    builder: (context,
                                                                            setState) =>
                                                                        AlertDialog(
                                                                          scrollable:
                                                                              true,
                                                                          backgroundColor: Theme.of(context)
                                                                              .colorScheme
                                                                              .background,
                                                                          title:
                                                                              const Text("Empty roooms"),
                                                                          content:
                                                                              Column(
                                                                            children: [
                                                                              // ListTile(
                                                                              //   title: Text("Day: ${hour["allRooms"][0].toString().substring(0, 10)}"),
                                                                              // ),
                                                                              // ListTile(
                                                                              //   title: Text("From: ${hour["allRooms"][1]}"),
                                                                              // ),
                                                                              // ListTile(
                                                                              //   title: Text("Until: ${hour["allRooms"][2]}"),
                                                                              // ),
                                                                              FutureBuilder(
                                                                                future: emptyRooms(hour["allRooms"][0], hour["allRooms"][1], hour["allRooms"][2]),
                                                                                builder: (context, snapshot) {
                                                                                  if (snapshot.hasData) {
                                                                                    return Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                      children: [
                                                                                        ...(snapshot.data as List).map((e) => Text(e.toString())).toList()
                                                                                      ],
                                                                                    );
                                                                                  } else {
                                                                                    return const Text("");
                                                                                  }
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )));
                                                        setState(() {});
                                                      },
                                                text:
                                                    "${hour["raum"]} ${hour["raum2"] != "" ? ' -  ${hour["raum2"]}' : hour["lehrer"]}\n",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                            TextSpan(
                                                text:
                                                    "${hour["fach"]} ${hour["fach2"] != "" && hour["fach2"] != hour["fach"] ? ' |  ${hour["fach2"]}' : ""}${viewNotes && (hour["notiz"] != "" || hour["notiz2"] != "") ? '\n${hour["notiz"] != "" ? hour["notiz"] : hour["notiz2"]}' : ''}",
                                                style: TextStyle(
                                                    color:
                                                        hour["istVertretung"] ==
                                                                true
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : hour["isExam"] &&
                                                                    viewExams
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error
                                                                : Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.color))
                                          ]))))
                                      .toList()))
                              .toList(),
                        );
                      },
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
