import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'file-helper-util.dart';
import 'package:http/http.dart' as http;
import './constants.dart' as constants;



Future<String?> getCountryFromCoordinates(
    double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      return placemarks.first.country;
    }
  } catch (e) {
    print("Error during reverse geocoding: $e");
  }
  return null;
}

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users to enable the location services.
    print('Location services are disabled.');
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      print('Location permissions are denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    print(
        'Location permissions are permanently denied, we cannot request permissions.');
    return null;
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

Future<List<String>> getFavoritesFromFile() async {
  bool fileExists = await checkIfFileExists("favorites.json");
  if (fileExists) {
    String filesDataString = await readFile("favorites.json");
    List<dynamic> filesData = json.decode(filesDataString);
    return filesData.map((f) => f.toString()).toList();
  }
  return List.empty(growable: true);
}

saveFavoritesFile(List<String> favoritesUUIDs) async {
  writeData("favorites.json", json.encode(favoritesUUIDs));
}



Future<List<String>> getRecentVisitsFromFile() async {
  bool fileExists = await checkIfFileExists("recentVisits.json");
  if (fileExists) {
    String filesDataString = await readFile("recentVisits.json");
    List<dynamic> filesData = json.decode(filesDataString);
    return filesData.map((f) => f.toString()).toList();
  }
  return List.empty(growable: true);
}

saveRecentVisitsFile(List<String> recentVisitsUUIDs) async {
  writeData("recentVisits.json", json.encode(recentVisitsUUIDs));
}

getStationsListForUUIDs(List<String> uuids) async {
var response = await http.get(Uri.parse('${constants.BASE_URL}stations/byuuid?uuids=${uuids.join(",")}'));
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
      return uniqueList;
    } else {
      throw Exception('Failed to load album');
    }
}

String getStationName(String? s) {
  if (s != null && s.isNotEmpty) {
    if (s.length > 24) {
      return '${s.substring(0, 21)}...';
    }
    return s;
  }
  else {
    return "";
  }
}
  
  String getStationCountry(String? country) {
    if (country != null && country.isNotEmpty) {
    if (country.length > 24) {
      return '(${country.substring(0, 21)}...)';
    }
    return '($country)';
  }
  else {
      return "";
    }
  }