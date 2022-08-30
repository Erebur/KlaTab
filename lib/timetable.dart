import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

Future<List<List>> loadTimeTable(token) async {
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
            "https://ux4.edvschule-plattling.de/klatab-reader/stundenplan/?typ=klasse&typValue=bfs2020fi&datum=2022-07-18"),
        headers: {
          "authorization": "Basic $token",
          "undefinedaccept": "application/json"
        });

    try {
      week = jsonDecode(response.body);
      if (kDebugMode) {
        print(jsonDecode(response.body)!);
        print(token!);
      }
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
        "raum2": currentHour2["raumId"]
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
  print(timetable);
  return timetable;
}
// {"fach": "Java","lehrer": "Ro","raum": 110,"istVertretung": true,"fach2": "MeSo","lehrer2": "Fe","raum2": 2025},
