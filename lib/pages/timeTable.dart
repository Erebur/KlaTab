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
import 'package:klatab/requests/timetable.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';

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
