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

import 'package:klatab/main.dart';

class PageFreeRooms extends StatefulWidget {
  const PageFreeRooms({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageFreeRoomsState();
}

class _PageFreeRoomsState extends State<PageFreeRooms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            TextButton.icon(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    surfaceTintColor: Colors.white),
                onPressed: () {},
                icon: const Icon(Icons.notes_outlined),
                label: const Text("toggle Notes"))
          ],
        ),
      ),
    );
  }
}
