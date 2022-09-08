import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:klatab/main.dart';

List _exams = [];
DateTime? _lastDay;
String? _lastGrade;

Future<List> loadExams() async {
  var monday = wantedWeek.subtract(Duration(days: wantedWeek.weekday - 1));

  if ((_lastDay != null &&
          monday.toString().substring(0, 11) ==
              _lastDay.toString().substring(0, 11)) &&
      (_lastGrade != null && _lastGrade == grade)) {
    return _exams;
  }
  _lastDay = monday;
  _lastGrade = grade;
  try {
    var response = await http.get(
        Uri.parse(
            "https://ux4.edvschule-plattling.de/klatab-reader/pruefungstermine/klasse?klasse=$grade&datum=${(wantedWeek == today ? wantedWeek : wantedWeek).subtract(Duration(days: wantedWeek.weekday - 1)).toString().substring(0, 10)}"),
        headers: {
          "authorization": "Basic $token",
          "content-type": "application/json"
        });

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
    _exams = jsonDecode(response.body)
        .map((item) => {
              "isExam": true,
              "fach": item["fach"],
              "lehrer": item["lehrer"],
              "raum": item["raum"],
              "art": item["art"],
              "bemerkung": item["bemerkung"],
              "start":
                  DateTime.parse(item["datum"]).add(stunden[item["von"] - 1][0])
              // .subtract(DateTime.now().timeZoneOffset)
              ,
              "start_hour": item["von"],
              "end":
                  DateTime.parse(item["datum"]).add(stunden[item["bis"] - 1][1])
              // .subtract(DateTime.now().timeZoneOffset)
              ,
              "end_hour": item["bis"],
              "link":
                  "https://www.google.com/calendar/render?action=TEMPLATE&text=${item["fach"]}+${item["art"]}&details=Lehrer%3A+${item["lehrer"]}&location=Raum%3A+${item["raum"]}&dates=${DateTime.parse(item["datum"]).add(stunden[item["von"] - 1][0]).toUtc().toIso8601String().replaceAll("-", "").replaceAll(":", "").replaceAll(".000", "")}%2F${DateTime.parse(item["datum"]).add(stunden[item["bis"] - 1][1]).toUtc().toIso8601String().replaceAll("-", "").replaceAll(":", "").replaceAll(".000", "")}",
            })
        .toList();
    if (addTermine) {
      var response = await http.get(
          Uri.parse(
              "https://ux4.edvschule-plattling.de/klatab-reader/termine?datum=${monday.toString().substring(0, 10)}"),
          headers: {
            "authorization": "Basic $token",
            "content-type": "application/json"
          });
      var jsonDecode2 = jsonDecode(response.body);
      _exams.addAll(jsonDecode2.map((item) {
        var start = DateTime.parse(item["datum_start"])
            .subtract(
                DateTime.parse(item["datum_start"]).toLocal().timeZoneOffset)
            .toLocal();
        var end = DateTime.parse(item["datum_ende"])
            .subtract(
                DateTime.parse(item["datum_ende"]).toLocal().timeZoneOffset)
            .toLocal()
            .add(const Duration(seconds: 1));
        return {
          "isExam": false,
          "fach": item["text"],
          "lehrer": "",
          "raum": "",
          "art": "Event",
          "bemerkung": "",
          "start": start,
          "start_hour": 0,
          // because why tf not
          "end": end,
          "end_hour": 0,
          "link":
              "https://www.google.com/calendar/render?action=TEMPLATE&text=${item["text"]}&dates=${start.toUtc().toIso8601String().replaceAll("-", "").replaceAll(":", "").replaceAll(".000", "")}%2F${end.toUtc().toIso8601String().replaceAll("-", "").replaceAll(":", "").replaceAll(".000", "")}",
        };
      }).toList());
    }
    return _exams
      ..sort(
        (a, b) => (a["start"] as DateTime).compareTo(b["start"] as DateTime),
      );
  } catch (e) {
    return [];
  }
}
