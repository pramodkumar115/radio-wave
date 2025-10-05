import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/TopHits/top_hits_service.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/radio_station.dart';

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

  Future<void> loadData() async {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      const Text("World's Top 10 Stations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      topHitStations.isNotEmpty
          ? RadioStationListView(stationList: topHitStations)
          : GFShimmer(child: emptyBlock)
    ]);
  }
}
