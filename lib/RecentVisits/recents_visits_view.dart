import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/RecentVisits/recent_visits_service.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class RecentVisitsView extends StatefulWidget {
  const RecentVisitsView({super.key});
  @override
  State<RecentVisitsView> createState() => _RecentVisitsViewState();
}

class _RecentVisitsViewState extends State<RecentVisitsView> {
  List<RadioStation> topHitStations = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var response = await getRecentVisitsList();
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
        margin: const EdgeInsets.only(top: 20),
        child: VStack([
          const Text("Recent Visits").text.scale(1.2).bold.make(),
          topHitStations.isNotEmpty
              ? RadioStationListView(stationList: topHitStations)
              : GFShimmer(child: emptyBlock)
        ]));
  }
}
