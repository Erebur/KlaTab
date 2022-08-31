import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:klatab/main.dart';

import 'exams.dart';

Future<List<List>> loadTimeTable(token) async {
  var monday = today.subtract(Duration(days: today.weekday - 1));

  Map week = {
    "montag": [],
    "dienstag": [],
    "mittwoch": [],
    "donnerstag": [],
    "freitag": []
  };

  var timetable = [[], [], [], [], [], [], [], [], [], [], []];
  var days = ["montag", "dienstag", "mittwoch", "donnerstag", "freitag"];

  if (token != null) {
    var response = await http.get(
        Uri.parse(
            "https://ux4.edvschule-plattling.de/klatab-reader/stundenplan/?typ=klasse&typValue=bfs2020fi&datum=${monday.toString().substring(0, 10)}"),
        headers: {
          "authorization": "Basic $token",
          "undefinedaccept": "application/json"
        });

    try {
      week = jsonDecode(response.body);
    } catch (e) {
      if (token != null) {
        Fluttertoast.showToast(
            msg: "not able to load Timetable",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            // backgroundColor:
            //     Theme.of(context).colorScheme.background,
            fontSize: 14.0);
      }
    }
  }

  for (var i = 0; i < 5; i++) {
    List? day = week[days[i]];
    int hour = 0;
    for (var ii = 0; ii < 11; ii++) {
      Map currentHour = {
        "fachKuerzel": "",
        "mitarbeiterKuerzel": "",
        "raumId": "",
        "istVertretung": "",
        "notiz": "",
        "gruppe": 0
      };
      Map currentHour2 = {
        "fachKuerzel": "",
        "mitarbeiterKuerzel": "",
        "raumId": "",
        "notiz": ""
      };

      if (day != null && day.length > hour && day[hour]["stunde"] == ii + 1) {
        currentHour = day[hour];

        if (currentHour["gruppe"] != 0 && day.length > hour + 1) {
          currentHour2 = day[hour + 1];
          if (currentHour["gruppe"] == 2 && currentHour2["gruppe"] == 1) {
            var tmp = currentHour;
            currentHour = currentHour2;
            currentHour2 = tmp;
          }
        }
      }

      timetable[ii].add({
        "fach": currentHour["fachKuerzel"],
        "lehrer": currentHour["mitarbeiterKuerzel"],
        "raum": currentHour["raumId"],
        "istVertretung": currentHour["istVertretung"],
        "notiz": currentHour["notiz"],
        "notiz2": currentHour2["notiz"],
        "fach2": currentHour2["fachKuerzel"],
        "lehrer2": currentHour2["mitarbeiterKuerzel"],
        "raum2": currentHour2["raumId"],
        "isExam": false
      });

      // if the group of the current dataset is not 0, then we have 2 entrys for one hour
      if (currentHour["gruppe"] != 0) {
        hour++;
      }
      if (day != null && day.length > hour && day[hour]["stunde"] == ii + 1) {
        hour++;
      }
    }
  }
  exams = await loadExams();
  // add exams
  for (var exam in exams) {
    if ((exam["start"] as DateTime).isAfter(monday) &&
        (exam["end"] as DateTime)
            .isBefore(monday.add(const Duration(days: 5)))) {
      for (var i = exam["start_hour"]; i <= exam["end_hour"]; i++) {
        timetable[i - 1][(exam["start"] as DateTime).weekday - 1] = {
          "fach": exam["fach"],
          "lehrer": exam["lehrer"],
          "raum": exam["raum"],
          "istVertretung": "false",
          "notiz": exam["bemerkung"],
          "notiz2": "",
          "fach2": "",
          "lehrer2": "",
          "raum2": exam["art"],
          "isExam": true
        };
      }
    }
  }

  return timetable;
}
