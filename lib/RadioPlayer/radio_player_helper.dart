import 'package:orbit_radio/model/radio_station.dart';

RadioStation? getSelectedRadioStation(
    List<RadioStation> radioStationsList, String selectedRadioId) {
  if (radioStationsList.isNotEmpty) {
    return radioStationsList
        .firstWhere((element) => element.stationUuid == selectedRadioId);
  }
  return null;
}
