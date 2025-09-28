import 'package:orbit_radio/model/radio_station.dart';
import 'package:collection/collection.dart';

RadioStation? getSelectedRadioStation(
    List<RadioStation> radioStationsList, String selectedRadioId) {
  if (radioStationsList.isNotEmpty) {
    return radioStationsList
        .firstWhereOrNull((element) => element.stationUuid == selectedRadioId);
  }
  return null;
}