import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/TopHits/top_hits_service.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class TopHitsView extends StatefulWidget {
  const TopHitsView({super.key});

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
      List<dynamic> stationList = jsonDecode(response.body);
      var list = stationList.map((d) => RadioStation.fromJson(d)).toList();
      setState(() {
        topHitStations.addAll(list);
      });
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // margin: const EdgeInsets.only(top: 20),
        child: VStack([
          const Text("World's Top 10 Stations").text.scale(1.1).fade.extraBlack.extraBold.make(),
          topHitStations.isNotEmpty
              ? RadioStationListView(stationList: topHitStations)
              : GFShimmer(child: emptyBlock)
        ]));
  }
}
