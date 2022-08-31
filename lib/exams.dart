import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:http/http.dart' as http;
import 'package:klatab/main.dart';

Future<List<Map>> loadExams() async {
  var response = await http.get(
      Uri.parse(
          "https://ux4.edvschule-plattling.de/klatab-reader/pruefungstermine/klasse?klasse=bfs2020fi&datum=2022-05-01"),
      headers: {
        "authorization": "Basic $token",
        "content-type": "application/json"
      });
  try {
    var stunden = const [
      [Duration(hours: 8, minutes: 00), Duration(hours: 8, minutes: 45)],
      [Duration(hours: 8, minutes: 45), Duration(hours: 9, minutes: 30)],
      [Duration(hours: 9, minutes: 30), Duration(hours: 10, minutes: 30)],
      [Duration(hours: 10, minutes: 30), Duration(hours: 11, minutes: 15)],
      [Duration(hours: 11, minutes: 30), Duration(hours: 12, minutes: 15)],
      [Duration(hours: 12, minutes: 15), Duration(hours: 13, minutes: 00)],
      [Duration(hours: 13, minutes: 00), Duration(hours: 13, minutes: 45)],
      [Duration(hours: 13, minutes: 45), Duration(hours: 14, minutes: 30)],
      [Duration(hours: 14, minutes: 45), Duration(hours: 15, minutes: 30)],
      [Duration(hours: 15, minutes: 30), Duration(hours: 16, minutes: 15)],
      [Duration(hours: 16, minutes: 15), Duration(hours: 17, minutes: 00)],
    ];
    // https://decomaan.github.io/google-calendar-link-generator/
    List exams = jsonDecode(response.body);
    var exams2 = exams
        .map((item) => {
              "fach": item["fach"],
              "lehrer": item["lehrer"],
              "raum": item["raum"],
              "art": item["art"],
              "start": DateTime.parse(item["datum"])
                  .add(stunden[item["von"] - 1][0])
                  .subtract(const Duration(hours: 2)),
              "start_hour": item["von"],
              "end": DateTime.parse(item["datum"])
                  .add(stunden[item["bis"] - 1][1])
                  .subtract(const Duration(hours: 2)),
              "end_hour": item["bis"],
              "link":
                  "https://www.google.com/calendar/render?action=TEMPLATE&text=${item["fach"]}+${item["art"]}&details=Lehrer%3A+${item["lehrer"]}&location=Raum%3A+${item["raum"]}&dates=${DateTime.parse(item["datum"]).add(stunden[item["von"] - 1][0]).toIso8601String().replaceAll("-", "").replaceAll(":", "").replaceAll(".000", "")}%2F${DateTime.parse(item["datum"]).add(stunden[item["bis"] - 1][1]).toIso8601String().replaceAll("-", "").replaceAll(":", "").replaceAll(".000", "")}",
            })
        .toList();
    return exams2;
  } catch (e) {
    return [];
  }
}
// https://www.google.com/calendar/render?action=TEMPLATE&text=PuG+KA&details=Lehrer%3A+me&location=Raum%3A+107&dates=2022-05-18T15:30:00.000Z%2F2022-05-18T15:30:00.000Z