import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:klatab/main.dart';

class PagePruefeungstermine extends StatefulWidget {
  const PagePruefeungstermine({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PagePruefeungstermineState();
}

class _PagePruefeungstermineState extends State<PagePruefeungstermine> {
  bool weeklyOverview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {
            setState(() {
              weeklyOverview = !weeklyOverview;
            });
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
      body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          child: Stack(
            children: [
              Visibility(
                maintainState: true,
                visible: weeklyOverview,
                child: Timetable(
                    controller:
                        TimetableController(start: today, cellHeight: 40),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                          ),
                        ),
                    items: exams
                        .map((item) => TimetableItem(item["start"], item["end"],
                            data: item))
                        .toList()),
              ),
              Visibility(
                  maintainState: true,
                  visible: !weeklyOverview,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: exams
                          .map(
                            (item) => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                item["isExam"]
                                    ? Expanded(
                                        child: Card(
                                          child: SizedBox(
                                            height: 130,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                        width: 70,
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                item["fach"],
                                                                style: TextStyle(
                                                                    color: item["art"] ==
                                                                            "SA"
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .primary
                                                                        : Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.color),
                                                              ),
                                                              Text(
                                                                item["art"],
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              )
                                                            ])),
                                                    Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(((item["start"]
                                                                      as DateTime)
                                                                  .toLocal()
                                                                  .toString())
                                                              .substring(
                                                                  0, 10)),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5),
                                                            child: Text(
                                                                "${((item["start"] as DateTime).toLocal().toString()).substring(11, 16)}-${((item["end"] as DateTime).toLocal().toString()).substring(11, 16)}"),
                                                          )
                                                        ]),
                                                    SizedBox(
                                                      width: 80,
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                                "${item["start_hour"]} - ${item["end_hour"]}"),
                                                            Text(
                                                                "${item["raum"]} - ${item["lehrer"]}")
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        launchUrl(
                                                            Uri.parse(
                                                                item["link"]),
                                                            mode: LaunchMode
                                                                .externalApplication);
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(Icons
                                                              .calendar_month),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .add,
                                                            style: TextStyle(
                                                                fontSize: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall
                                                                    ?.fontSize),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: Card(
                                          child: SizedBox(
                                            height: 130,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                        width: 300,
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                item["fach"],
                                                                style: TextStyle(
                                                                    color: item["art"] ==
                                                                            "SA"
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .primary
                                                                        : Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.color),
                                                              ),
                                                              Text(
                                                                item["art"],
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              )
                                                            ])),
                                                    SizedBox(
                                                        width: 150,
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                (item["start"]
                                                                        as DateTime)
                                                                    .toLocal()
                                                                    .toString()
                                                                    .substring(
                                                                        0, 11),
                                                              ),
                                                            ])),
                                                    TextButton(
                                                      onPressed: () {
                                                        launchUrl(
                                                            Uri.parse(
                                                                item["link"]),
                                                            mode: LaunchMode
                                                                .externalApplication);
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(Icons
                                                              .calendar_month),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .add,
                                                            style: TextStyle(
                                                                fontSize: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall
                                                                    ?.fontSize),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ]),
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
          )),
    );
  }
}
