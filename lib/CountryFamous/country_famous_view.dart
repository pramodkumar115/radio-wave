import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:orbit_radio/CountryFamous/country_famous_service.dart';
import 'package:orbit_radio/Notifiers/country_state_notifier.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/model/radio_station.dart';

class CountryFamousStationsView extends ConsumerStatefulWidget {
  const CountryFamousStationsView({super.key});

  @override
  ConsumerState<CountryFamousStationsView> createState() =>
      _CountryFamousStationsViewState();
}

class _CountryFamousStationsViewState
    extends ConsumerState<CountryFamousStationsView> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<RadioStation>> loadData() async {
    final country = ref.watch(countryProvider);
    var response = await getCountryFamousStationDetails(country);
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
      const Text("Famous stations near you",
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
