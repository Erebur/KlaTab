import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:klatab/main.dart';

class PageExams extends StatefulWidget {
  const PageExams({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageExamsState();
}

class _PageExamsState extends State<PageExams> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {
            setState(() => weeklyOverview = !weeklyOverview);
            hiveBox.put('weeklyOverview', weeklyOverview);
          },
          child: Text(
            weeklyOverview
                ? AppLocalizations.of(context)!.calendar
                : AppLocalizations.of(context)!.compact,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        // toolbarHeight:
        //     (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 10) + 10,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Stack(
        children: [
          Visibility(
            maintainState: true,
            visible: weeklyOverview,
            child: Timetable(
                controller: TimetableController(
                    start: wantedWeek == today
                        ? wantedWeek
                        : wantedWeek
                            .subtract(Duration(days: wantedWeek.weekday - 1)),
                    cellHeight: 40),
                itemBuilder: (item) => Container(
                      decoration: BoxDecoration(
                        color: (item.data as Map)["art"] == "SA"
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: Center(
                          child: Text(
                            "${(item.data as Map)["fach"]} ${(item.data as Map)["art"]}",
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).colorScheme.background),
                          ),
                        ),
                      ),
                    ),
                items: exams
                    .map((item) =>
                        TimetableItem(item["start"], item["end"], data: item))
                    .toList()),
          ),
          Visibility(
              maintainState: true,
              visible: !weeklyOverview,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: exams
                      .map(
                        (item) => Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 5),
                                child: Card(
                                  child: SizedBox(
                                    height: 130,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                              child: item["isExam"]
                                                  ? examsItem(item)
                                                  : eventItem(item)),
                                          TextButton(
                                              onPressed: () => launchUrl(
                                                  Uri.parse(item["link"]),
                                                  mode: LaunchMode
                                                      .externalApplication),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_month),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .add,
                                                      style: TextStyle(
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.fontSize),
                                                    )
                                                  ]))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ))
        ],
      ),
    );
  }

  Widget eventItem(item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              item["fach"],
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: item["art"] == "SA"
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyMedium?.color),
            ),
            Text(
              item["art"],
              style: Theme.of(context).textTheme.bodySmall,
            )
          ]),
        ),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (item["start"] as DateTime)
                          .toString()
                          .substring(0, 11) !=
                      (item["end"] as DateTime).toString().substring(0, 11)
                  ? [
                      Text(
                        (item["start"] as DateTime).toString().substring(0, 11),
                      ),
                      Text(
                        (item["end"] as DateTime).toString().substring(0, 11),
                      )
                    ]
                  : [
                      Text(
                        (item["start"] as DateTime).toString().substring(0, 11),
                      ),
                      Text(
                        (item["start"] as DateTime)
                                    .toString()
                                    .substring(11, 16) ==
                                "00:00"
                            ? ""
                            : "${(item["start"] as DateTime).toString().substring(11, 16)}-${(item["end"] as DateTime).toString().substring(11, 16)}",
                      ),
                    ]),
        ),
      ],
    );
  }

  Widget examsItem(item) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text(
              item["fach"],
              style: TextStyle(
                  color: item["art"] == "SA"
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyMedium?.color),
            ),
            Text(
              item["art"],
              style: Theme.of(context).textTheme.bodySmall,
            )
          ])),
      Expanded(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(((item["start"] as DateTime).toLocal().toString())
                  .substring(0, 10)),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                    "${((item["start"] as DateTime).toLocal().toString()).substring(11, 16)}-${((item["end"] as DateTime).toLocal().toString()).substring(11, 16)}"),
              )
            ]),
      ),
      Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${item["start_hour"]} - ${item["end_hour"]}"),
              Text("${item["raum"]} - ${item["lehrer"]}")
            ],
          ),
        ),
      )
    ]);
  }
}
