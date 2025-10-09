import 'dart:convert';

import 'package:orbit_radio/model/radio_station.dart';

class PlayListItem {
  String id = "";
  String name = "";
  List<RadioStation> radioStations;

  PlayListItem({required this.id, required this.name, required this.radioStations});
}

class PlayListJsonItem {
  String id = "";
  String name = "";
  List<String> stationIds;

  PlayListJsonItem({required this.id, required this.name, required this.stationIds});

  Map<String, dynamic> toJson() {
    return {"id": id, 'name': name, 'stationIds': jsonEncode(stationIds)};
  }
}
