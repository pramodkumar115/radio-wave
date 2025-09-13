import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/TopHits/top_hits_service.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class TopHitsView extends StatefulWidget {
  const TopHitsView({Key? key}) : super(key: key);

  @override
  State<TopHitsView> createState() => _TopHitsViewState();
}

class _TopHitsViewState extends State<TopHitsView> {
  List<RadioStation> topHitStations = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var response = await getTopHitStationDetails();
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> stationList = jsonDecode(response.body);
      // print("stationList: $stationList");
      var list = stationList.map((d) => RadioStation.fromJson(d)).toList();
      print(list);
      setState(() {
        topHitStations.addAll(list);
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
        child: VStack([
      const Text("World's Top 10 Voted Radio Stations")
          .text
          .scale(1.2)
          .bold
          .make(),
      topHitStations.isNotEmpty
          ? RadioStationListView(stationList: topHitStations)
          : GFShimmer(child: emptyBlock)
    ]));
  }
}
