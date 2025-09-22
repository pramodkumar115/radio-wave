import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/CountryFamous/country_famous_service.dart';
import 'package:orbit_radio/Notifiers/country_state_notifier.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class CountryFamousStationsView extends ConsumerStatefulWidget {
  const CountryFamousStationsView({super.key});

  @override
  ConsumerState<CountryFamousStationsView> createState() =>
      _CountryFamousStationsViewState();
}

class _CountryFamousStationsViewState
    extends ConsumerState<CountryFamousStationsView> {
  List<RadioStation> topHitStations = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      loadData();
    });
  }

  loadData() async {
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
      if (kDebugMode) {
        // print(uniqueList);
      }
      setState(() {
        topHitStations.addAll(uniqueList);
      });
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return VStack([
          const Text("Famous stations near you").text.scale(1.1).bold.make(),
          topHitStations.isNotEmpty
              ? RadioStationListView(stationList: topHitStations)
              : GFShimmer(child: emptyBlock)
        ]);
  }
}
