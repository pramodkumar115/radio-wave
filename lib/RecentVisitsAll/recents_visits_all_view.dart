import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Search/search_service.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class RecentsVisitsAllView extends StatefulWidget {
  const RecentsVisitsAllView({super.key, required this.stationsList});
  final List<RadioStation> stationsList;

  @override
  State<RecentsVisitsAllView> createState() => _RecentsVisitsAllViewState();
}

class _RecentsVisitsAllViewState extends State<RecentsVisitsAllView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [GestureDetector(
            child: Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: Text("Clear History").text.underline.make()
            ),
          )],
          title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text("Recent Visits").text.bold.xl.make(),
          ]),
          backgroundColor: Colors.grey.shade100,
        ),
        body: widget.stationsList.isNotEmpty
            ? ListView(children: [
                ...widget.stationsList.map((radio) {
                  return RadioTile(
                      radio: radio,
                      radioStations: widget.stationsList,
                      from: "RECENT_VISITS");
                }),
              ])
            : Container());
  }
}
