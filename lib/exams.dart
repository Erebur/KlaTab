import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:klatab/main.dart';

Future<List> loadExams() async {
  var response = await http.get(
      Uri.parse(
          "https://ux4.edvschule-plattling.de/klatab-reader/pruefungstermine/klasse?klasse=bfs2020fi&datum=2022-05-01"),
      headers: {
        "authorization": "Basic $token",
        "content-type": "application/json"
      });
  try {
    if (kDebugMode) {
      print(jsonDecode(response.body));
      print(token);
    }
    return jsonDecode(response.body);
  } catch (e) {
    return [];
  }
}
