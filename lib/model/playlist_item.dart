import 'dart:convert';

import 'package:orbit_radio/model/radio_station.dart';

class PlayListItem {
  String name = "";
  List<RadioStation> radioStations;

  PlayListItem({required this.name, required this.radioStations});
}

class PlayListJsonItem {
  String name = "";
  List<String> stationIds;

  PlayListJsonItem({required this.name, required this.stationIds});

  Map<String, dynamic> toJson() {
    return {'name': name, 'stationIds': jsonEncode(stationIds)};
  }
}
