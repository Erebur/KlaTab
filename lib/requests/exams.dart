import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:klatab/main.dart';

Future<List> loadExams() async {
  var monday = today.subtract(Duration(days: today.weekday - 1));
  try {
    var response = await http.get(
        Uri.parse(
            "https://ux4.edvschule-plattling.de/klatab-reader/pruefungstermine/klasse?klasse=bfs2020fi&datum=${monday.toString().substring(0, 10)}"),
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
    var exams = jsonDecode(response.body)
        .map((item) => {
              "isExam": true,
              "fach": item["fach"],
              "lehrer": item["lehrer"],
              "raum": item["raum"],
              "art": item["art"],
              "bemerkung": item["bemerkung"],
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
    if (addTermine) {
      var response = await http.get(
          Uri.parse(
              "https://ux4.edvschule-plattling.de/klatab-reader/termine?datum=${monday.toString().substring(0, 10)}"),
          headers: {
            "authorization": "Basic $token",
            "content-type": "application/json"
          });
      var jsonDecode2 = jsonDecode(response.body);
      exams.addAll(jsonDecode2
          .map((item) => {
                "isExam": false,
                "fach": item["text"],
                "lehrer": "",
                "raum": "",
                "art": "Event",
                "bemerkung": "",
                "start": DateTime.parse(item["datum_start"]),
                "start_hour": 0,
                // because why tf not
                "end": DateTime.parse(item["datum_ende"])
                    .add(const Duration(seconds: 1)),
                "end_hour": 0,
                "link":
                    "https://www.google.com/calendar/render?action=TEMPLATE&text=${item["text"]}+Event&dates=${DateTime.parse(item["datum_start"])}%2F${DateTime.parse(item["datum_ende"])}",
              })
          .toList());
    }
    return exams;
  } catch (e) {
    print(e);
    return [];
  }
}
// https://www.google.com/calendar/render?action=TEMPLATE&text=PuG+KA&details=Lehrer%3A+me&location=Raum%3A+107&dates=2022-05-18T15:30:00.000Z%2F2022-05-18T15:30:00.000Z

// <DataColumn>[
//                         DataColumn(
//                             label: Text(),
//                         DataColumn(
//                             label: Text()),
//                         DataColumn(
//                             label:
//                                 Text()),
//                         DataColumn(
//                             label:
//                                 Text()),
//                         DataColumn(
//                             label: Text(AppLocalizations.of(context)!.friday)),
//                       ],
