import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:klatab/main.dart';

Future<List> loadRooms(stunde1, stunde2, {Function()? onNetworkError}) async {
  var response;
  try {
    response = await http.get(
        Uri.parse(
            "https://11.edvschule-plattling.de/klatab-reader/freie-raeume/heute?stundeVon=$stunde1&stundeBis=$stunde2"),
        headers: {
          "authorization": "Basic $token",
          "undefinedaccept": "application/json"
        });
    return jsonDecode(response.body).map((value) {
      return value["raumNr"];
    }).toList();
  } catch (e) {
    onNetworkError!.call();
    return [];
  }
}
