import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orbit_radio/model/playlist_item.dart';
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
    // print("Error during reverse geocoding: $e");
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
    // print('Location services are disabled.');
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
      // print('Location permissions are denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    // print(
    // 'Location permissions are permanently denied, we cannot request permissions.');
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

Future<void> saveFavoritesFile(List<String> favoritesUUIDs) async {
  writeData("favorites.json", json.encode(favoritesUUIDs));
}

Future<List<PlayListJsonItem>> getPlayListsFromFile() async {
  bool fileExists = await checkIfFileExists("playlist.json");
  if (fileExists) {
    String filesDataString = await readFile("playlist.json");
    List<dynamic> filesData = json.decode(filesDataString);
    List<PlayListJsonItem> list = List.empty(growable: true);
    
    for (var i =0; i < filesData.length; i++) {
      var f = filesData[i];
      var item = PlayListJsonItem(
          name: f["name"],
          stationIds: jsonDecode(f["stationIds"]).cast<String>()
      );
      debugPrint("item - $item");
      list.add(item);
    }
    return list;
  }
  return List.empty(growable: true);
}

Future<void> savePlaylistFile(List<PlayListJsonItem> playListData) async {
  debugPrint(
      "playListData - ${playListData.toString()}, ${json.encode(playListData)}");
  writeData("playlist.json", json.encode(playListData));
}
Future<List<RadioStation>> getAddedStreamsFromFile() async {
  bool fileExists = await checkIfFileExists("addedstreams.json");
  if (fileExists) {
    String filesDataString = await readFile("addedstreams.json");
    List<dynamic> filesData = json.decode(filesDataString);
    List<RadioStation> list = List.empty(growable: true);
    
    for (var i =0; i < filesData.length; i++) {
      var f = filesData[i];
      var item = RadioStation.fromJson(f);
      debugPrint("Added item - $item");
      list.add(item);
    }
    return list;
  }
  return List.empty(growable: true);
}

Future<void> saveAddedStreamsFile(List<RadioStation> playListData) async {
  debugPrint(
      "addedstreams - ${playListData.toString()}, ${json.encode(playListData)}");
  writeData("addedstreams.json", json.encode(playListData));
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

Future<void> saveRecentVisitsFile(List<String> recentVisitsUUIDs) async {
  writeData("recentVisits.json", json.encode(recentVisitsUUIDs));
}

Future<List<RadioStation>> getStationsListForUUIDs(List<String> uuids) async {
  var response = await http.get(Uri.parse(
      '${constants.BASE_URL}stations/byuuid?uuids=${uuids.join(",")}'));
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
  } else {
    return "";
  }
}

String getStationCountry(String? country) {
  if (country != null && country.isNotEmpty) {
    if (country.length > 24) {
      return '(${country.substring(0, 21)}...)';
    }
    return '($country)';
  } else {
    return "";
  }
}

 RadioStation convertMediaItemToRadio(MediaItem currentMediaItem) {
    return RadioStation(
        stationUuid: currentMediaItem.id,
        country: currentMediaItem.artist,
        name: currentMediaItem.album,
        favicon: currentMediaItem.artUri?.toString(),
        tags: currentMediaItem.genre);
  }

List<RadioStation> converMediaItemsToRadioList(
      List<MediaItem?>? playListMediaItems) {
    List<RadioStation> stations = List.empty(growable: true);
    if (playListMediaItems != null) {
      for (var i = 0; i < playListMediaItems.length; i++) {
        if (playListMediaItems[i] != null) {
          stations.add(convertMediaItemToRadio(playListMediaItems[i]!));
        }
      }
    }
    return stations;
  }