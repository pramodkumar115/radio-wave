import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/recent_visits_notifier.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';

class RecentsVisitsAllView extends ConsumerStatefulWidget {
  const RecentsVisitsAllView({super.key});

  @override
  ConsumerState<RecentsVisitsAllView> createState() =>
      _RecentsVisitsAllViewState();
}

class _RecentsVisitsAllViewState extends ConsumerState<RecentsVisitsAllView> {
  late Future<List<RadioStation>> _recentsViewsFuture;

  @override
  void initState() {
    super.initState();
    _recentsViewsFuture = loadData();
  }

  Future<List<RadioStation>> loadData() async {
    List<String> uuids = await getRecentVisitsFromFile();
    return await getStationsListForUUIDs(uuids);
  }

  void _refreshFuture() {
    // 3. Call setState and re-assign the Future variable to a new Future.
    setState(() {
      _recentsViewsFuture = loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Allow pop if no unsaved changes
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            print("came in $didPop");
          } else {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              actions: [
                GestureDetector(
                  child: Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: Text("Clear History",
                          style:
                              TextStyle(decoration: TextDecoration.underline))),
                  onTap: () {
                    ref
                        .watch(recentVisitsDataProvider.notifier)
                        .updateRecentVisits([]);
                    _refreshFuture();
                  },
                )
              ],
              title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text("Recent Visits",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
              ]),
              backgroundColor: Colors.grey.shade100,
            ),
            body: FutureBuilder(
                future: _recentsViewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return showContent(snapshot.data);
                  } else {
                    return GFShimmer(child: emptyCardBlock);
                  }
                })));
  }

  Widget showContent(List<RadioStation>? stationsList) {
    return stationsList != null && stationsList.isNotEmpty
        ? ListView(children: [
            ...stationsList!.map((radio) {
              return RadioTile(
                  radio: radio,
                  radioStations: stationsList,
                  from: "RECENT_VISITS");
            }),
          ])
        : Text("No history of radios yet");
  }
}
