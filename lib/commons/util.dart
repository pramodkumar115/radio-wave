    import 'dart:convert';

import 'package:geolocator/geolocator.dart';
    import 'package:geocoding/geocoding.dart';
    import 'file-helper-util.dart';

    Future<String?> getCountryFromCoordinates(double latitude, double longitude) async {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
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
        print('Location permissions are permanently denied, we cannot request permissions.');
        return null;
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition();
    }

    Future<List<String>> getFavoritesFromFile() async{
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