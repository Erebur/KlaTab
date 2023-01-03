import 'dart:convert';
import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:klatab/main.dart';
import 'package:klatab/requests/rooms.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'exams.dart';

// german because the api is german
Map week = {
  "montag": [],
  "dienstag": [],
  "mittwoch": [],
  "donnerstag": [],
  "freitag": []
};
DateTime? _lastDay;
String? _lastGrade;

Future<List<List>> loadTimeTable(context, token, dryRun) async {
  var monday = wantedWeek.subtract(Duration(
      days: wantedWeek.weekday - 1,
      hours: wantedWeek.hour,
      minutes: wantedWeek.minute,
      seconds: wantedWeek.second));

  if (!dryRun) {
    try {
      http.Response response = await http.get(
          Uri.parse(
              "https://ux4.edvschule-plattling.de/klatab-reader/stundenplan/?typ=klasse&typValue=$grade&datum=${monday.toString().substring(0, 10)}"),
          headers: {
            "authorization": "Basic $token",
            "undefinedaccept": "application/json"
          });
      if (viewExams) {
        exams = await loadExams();
      }
      week = jsonDecode(response.body);
      offline = false;
    } catch (e) {
      offline = true;
      Map? cache =
          hiveBox.get('cached_week_${monday.toString().substring(0, 10)}');
      if (cache != null) {
        week = cache['week'];
        exams = cache['exams'];
      } else {
        week = {
          "montag": [],
          "dienstag": [],
          "mittwoch": [],
          "donnerstag": [],
          "freitag": []
        };
        exams = [];
      }
    }
  }

  if (token != null && grade == null) {
    setGrade();
  }

  if (token != null) {
    _lastDay = monday;
    _lastGrade = grade;
  }

  List<List> timetable = [[], [], [], [], [], [], [], [], [], [], []];
  var days = ["montag", "dienstag", "mittwoch", "donnerstag", "freitag"];

  for (var i = 0; i < 5; i++) {
    List? day = week[days[i]];
    int hour = 0;
    for (var ii = 0; ii < 11; ii++) {
      Map currentHour = {
        "fachKuerzel": "",
        "mitarbeiterKuerzel": "",
        "raumId": "                           ",
        "istVertretung": "",
        "notiz": "",
        "gruppe": 0
      };
      Map currentHourNextGroup = {
        "fachKuerzel": "",
        "mitarbeiterKuerzel": "",
        "raumId": "",
        "notiz": ""
      };
      if (day != null &&
          day.length > hour + 2 &&
          day[hour]["stunde"] == day[hour + 1]["stunde"] &&
          day[hour + 1]["stunde"] == day[hour + 2]["stunde"] &&
          (day[hour]["gruppe"] == 0 ||
              day[hour + 1]["gruppe"] == 0 ||
              day[hour + 2]["gruppe"] == 0)) {
        // wtf how bad is this api, seriously why ?
        var h1 = day[hour];
        var h2 = day[hour + 1];
        var h3 = day[hour + 2];
        if (h1["gruppe"] == 0) {
          day.remove(h1);
        } else {
          day.remove(h1);
          day.remove(h2);
        }
        ii--;
        // day.removeWhere((element) =>
        //     element["stunde"] == ii &&
        //     (element["gruppe"] == 0 && element["istVertretung"] == true));

        continue;
      }

      if (day != null && day.length > hour && day[hour]["stunde"] == ii + 1) {
        // if there is no entry for this hour dont try and load one
        currentHour = day[hour];

        if (currentHour["gruppe"] != 0 && day.length > hour + 1) {
          // check if the next entry is the same hour but another group
          currentHourNextGroup = day[hour + 1];
          if (currentHour["gruppe"] == 2 &&
              currentHourNextGroup["gruppe"] == 1) {
            var tmp = currentHour;
            currentHour = currentHourNextGroup;
            currentHourNextGroup = tmp;
          }
        }
      }

      timetable[ii].add({
        "new_subject": group == 1
            ? currentHour["fachKuerzel"]
            : currentHourNextGroup["fachKuerzel"] != ""
                ? currentHourNextGroup["fachKuerzel"]
                : currentHour["fachKuerzel"],
        "new_room": group == 1
            ? currentHour["raumId"]
            : currentHourNextGroup["raumId"] != ""
                ? currentHourNextGroup["raumId"]
                : currentHour["raumId"],
        "new_teacher": group == 1
            ? currentHour["mitarbeiterKuerzel"]
            : currentHourNextGroup["mitarbeiterKuerzel"] != ""
                ? currentHourNextGroup["mitarbeiterKuerzel"]
                : currentHour["mitarbeiterKuerzel"],
        "new_substitution": group == 1
            ? currentHour["istVertretung"]
            : currentHourNextGroup["istVertretung"] != ""
                ? currentHourNextGroup["istVertretung"]
                : currentHour["istVertretung"],
        "new_note": group == 1
            ? currentHour["notiz"]
            : currentHourNextGroup["notiz"] != ""
                ? currentHourNextGroup["notiz"]
                : currentHour["notiz"],
        "fach": currentHour["fachKuerzel"],
        "lehrer": currentHour["mitarbeiterKuerzel"],
        "raum": currentHour["raumId"],
        "istVertretung": currentHour["istVertretung"] == true,
        "istVertretung2": currentHourNextGroup["istVertretung"] == true,
        "notiz": currentHour["notiz"],
        "notiz2": currentHourNextGroup["notiz"],
        "fach2": currentHourNextGroup["fachKuerzel"],
        "lehrer2": currentHourNextGroup["mitarbeiterKuerzel"],
        "raum2": currentHourNextGroup["raumId"],
        "isExam": false,
        "isRoom": false,
        "allRoomsFun": emptyRooms,
        "allRooms": [monday.add(Duration(days: i)), ii + 1, ii + 1]
      });

      // if the group of the current dataset is not 0, then we have 2 entrys for one hour
      if (currentHour["gruppe"] != 0) {
        hour++;
      }

      if (day != null && day.length > hour && day[hour]["stunde"] == ii + 1) {
        hour++;
      } else if (viewRooms &&
          day != null &&
          day.length > hour + 1 &&
          day[hour + 1] != null) {
        // empty rooms to stay in your brake
        rooms = await loadRooms(monday.add(Duration(days: i)), ii + 1, ii + 1);

        var wantedRooms = {
          day[hour]["gruppe"] == 0 || day[hour]["gruppe"] == group
              ? day[hour]["raumId"]
              : day[hour + 1]["raumId"],
          timetable[ii - 1][i]["raum"],
          ...wantedRoomsUserdefined.toSet()
        };

        timetable[ii][i]
          ..["isRoom"] = true
          ..["raum"] = wantedRooms.intersection(rooms).toList()[0];
      }
    }
  }

  if (viewExams) {
    // add exams
    for (var exam in exams.where((element) => element["isExam"])) {
      if ((exam["start"] as DateTime).isAfter(monday) &&
          (exam["end"] as DateTime)
              .isBefore(monday.add(const Duration(days: 5)))) {
        for (var i = exam["start_hour"]; i <= exam["end_hour"]; i++) {
          timetable[i - 1][(exam["start"] as DateTime).weekday - 1]
            ..["fach"] = exam["fach"]
            ..["lehrer"] = exam["lehrer"]
            ..["raum"] = exam["raum"].toString()
            ..["istVertretung"] = "false"
            ..["notiz"] = exam["bemerkung"]
            ..["notiz2"] = ""
            ..["fach2"] = ""
            ..["lehrer2"] = ""
            ..["raum2"] = exam["art"]
            ..["isExam"] = true
            ..["new_subject"] = exam["fach"]
            ..["new_teacher"] = exam["lehrer"]
            ..["new_room"] = exam["raum"].toString();
        }
      }
    }
  }

  if ((week["montag"]! as List).isNotEmpty || exams.isNotEmpty && !offline) {
    await hiveBox.put('cached_week_${monday.toString().substring(0, 10)}',
        {"monday": monday, "week": week, "exams": exams});
  }

  return timetable;
}

Future<List> emptyRooms(day, stunde1, stunde2) async {
  Set freeRoms = await loadRooms(day, stunde1, stunde2);
  var wantedFreeRooms = wantedRoomsUserdefined.toSet().intersection(freeRoms);

  return {...wantedFreeRooms, ...freeRoms}.toList();
}
