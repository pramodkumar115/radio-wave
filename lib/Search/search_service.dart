import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../commons/constants.dart' as constants;

Future<dynamic> getSearchResults(
    String text, String searchBy, int startIndex, int endIndex) async {
  debugPrint(
      '${constants.BASE_URL}stations/$searchBy/${text.toLowerCase()}?offset=$startIndex&limit=$endIndex');
  return await http.get(Uri.parse(
      '${constants.BASE_URL}stations/$searchBy/${text.toLowerCase()}?offset=$startIndex&limit=$endIndex'));
}

Future<dynamic> getAdvancedSearchResults(String stationName, String country,
    String language, String tag, int startIndex, int endIndex) async {
  List<String> searchString = List.empty(growable: true);
  if (stationName.isNotEmpty) {
    searchString.add("name=${stationName.trim().toLowerCase()}");
  }
  if (country.isNotEmpty) {
    searchString.add("country=$country");
  }
  if (tag.isNotEmpty) {
    searchString.add("tagList=$tag");
  }
  if (language.isNotEmpty) {
    searchString.add("language=${language.trim().toLowerCase()}");
  }
  debugPrint(
      "${constants.BASE_URL}stations/search?${searchString.join("&")}&offset=$startIndex&limit=$endIndex");
  if (searchString.isNotEmpty) {
    return await http.get(Uri.parse(
        '${constants.BASE_URL}stations/search?${searchString.join("&")}&offset=$startIndex&limit=$endIndex'));
  }
  return [];
}

Future<List<String>> getCountryList(String country) async {
  var response = await http.get(Uri.parse("${constants.BASE_URL}countries"));
  List<String> countries = List.empty(growable: true);
  if (response.statusCode == 200) {
    List<dynamic> countryData = jsonDecode(response.body);
    countries.addAll(countryData.map((e) => e['name']));
  }
  debugPrint("countries - $countries");
  return countries
      .where((e) => e.toLowerCase().contains(country.toLowerCase()))
      .toList();
}
