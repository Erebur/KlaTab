import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:klatab/main.dart';

Future<Set> loadRooms(DateTime date, stunde1, stunde2,
    {Function()? onNetworkError}) async {
  var response;
  try {
    response = await http.get(
        Uri.parse(
            "https://ux4.edvschule-plattling.de/klatab-reader/freie-raeume/?datum=${date.toString().substring(0, 10)}&stundeVon=$stunde1&stundeBis=$stunde2"),
        headers: {
          "authorization": "Basic $token",
          "undefinedaccept": "application/json"
        });
    List jsonDecode2 = jsonDecode(response.body).map((value) {
      return value["raumNr"];
    }).toList();
    return jsonDecode2.toSet();
  } catch (e) {
    onNetworkError!.call();
    return {};
  }
}
