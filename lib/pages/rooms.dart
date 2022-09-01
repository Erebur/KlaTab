import 'package:flutter/material.dart';
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
          children: rooms.map((e) => Text(e.toString())).toList(),
        ),
      ),
    );
  }
}
