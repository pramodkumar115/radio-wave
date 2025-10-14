import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/TopHits/top_hits_service.dart';
import 'package:orbit_radio/model/radio_station.dart';

class TopHitsView extends StatefulWidget {
  const TopHitsView({super.key});

  @override
  State<TopHitsView> createState() => _TopHitsViewState();
}

class _TopHitsViewState extends State<TopHitsView> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<List<RadioStation>> loadData() async {
    var response = await getTopHitStationDetails();
    if (response.statusCode == 200) {
      List<dynamic> stationList = jsonDecode(response.body);
      var list = stationList.map((d) => RadioStation.fromJson(d)).toList();
      list.sort((a, b) => a.votes! > b.votes! ? 1 : -1);
      List<RadioStation> uniqueList = List.empty(growable: true);
      for (int i = 0; i < list.length; i++) {
        RadioStation element = list[i];
        if (uniqueList.where((data) => data.name == element.name).isEmpty) {
          uniqueList.add(element);
        }
      }
      return uniqueList;
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("World's Top Radio Stations",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          return Skeleton(
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              skeleton: SkeletonListTile(),
              child: snapshot.data != null && snapshot.data!.isNotEmpty
                  ? RadioStationListView(stationList: snapshot.data!)
                  : Text("No radio stations to show for now"));
        },
      )
    ]);
  }
}
