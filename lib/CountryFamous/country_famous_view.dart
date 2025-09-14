import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/CountryFamous/country_famous_service.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class CountryFamousStationsView extends StatefulWidget {
  const CountryFamousStationsView({super.key, required this.countryName, required this.favoritesData, required this.loadAllData});
  final String? countryName;
    final List<dynamic>? favoritesData;
        final Function loadAllData;



  @override
  State<CountryFamousStationsView> createState() =>
      _CountryFamousStationsViewState();
}

class _CountryFamousStationsViewState extends State<CountryFamousStationsView> {
  List<RadioStation> topHitStations = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var response = await getCountryFamousStationDetails(widget.countryName);
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
        print(uniqueList);
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
    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: VStack([
          Text("${widget.countryName}'s famous station")
              .text
              .scale(1.2)
              .bold
              .make(),
          topHitStations.isNotEmpty
              ? RadioStationListView(stationList: topHitStations, favoritesData: widget.favoritesData, loadAllData: widget.loadAllData)
              : GFShimmer(child: emptyBlock)
        ]));
  }
}
