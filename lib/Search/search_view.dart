import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Search/search_service.dart';
import 'package:orbit_radio/components/favorites_button.dart';
import 'package:orbit_radio/components/play_stop_button.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  int startIndex = 0, endIndex = 10;
  List<RadioStation> searchedRadioStations = List.empty(growable: true);
  Set<String> searchType = {'byname'};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(loadData);
  }

  void loadData() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      String text = _searchController.text;
      if (text.length >= 3) {
        var response = await getSearchResults(
            text.trim(), searchType.first, startIndex, endIndex);
        if (response.statusCode == 200) {
          List<dynamic> stationList = jsonDecode(response.body);
          var list = stationList.map((d) => RadioStation.fromJson(d)).toList();
          print("list - ${response.body}");
          setState(() {
            searchedRadioStations.clear();
            searchedRadioStations.addAll(list);
          });
        } else {
          throw Exception('Failed to load album');
        }
      } else {
        setState(() => searchedRadioStations.clear());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(loadData);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              const Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text("Search"),
          ]),
          backgroundColor: Colors.grey.shade100,
        ),
        body: Column(children: [
          SegmentedButton(
              emptySelectionAllowed: false,
              multiSelectionEnabled: false,
              showSelectedIcon: false,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    // Return a different color for the selected segment
                    if (states.contains(WidgetState.selected)) {
                      return Color.fromARGB(255, 0, 29, 10);
                    }
                    // Return a default color for unselected segments
                    return Colors.grey.shade200;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    // Return a different color for the selected segment
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    // Return a default color for unselected segments
                    return Colors.black;
                  },
                ),
              ),
              segments: const <ButtonSegment<String>>[
                ButtonSegment(value: 'byname', label: Text('By Name')),
                ButtonSegment(value: 'bycountry', label: Text('By Country')),
                ButtonSegment(value: 'bytag', label: Text('By Hashtag')),
                ButtonSegment(value: 'bylanguage', label: Text('By Language')),
              ],
              selected: searchType,
              onSelectionChanged: (Set<String> value) {
                setState(() {
                  searchType = value;
                  searchedRadioStations.clear();
                });
                Future.delayed(Duration.zero, () async {
                  if (_searchController.text.length >= 3) {
                    loadData();
                  }
                });
              }),
          TextField(
            enableSuggestions: false,
            textInputAction: TextInputAction.search,
            controller: _searchController,
            decoration: const InputDecoration(
                labelText: 'Enter station name, country, language, tags etc'),
          ),
          searchedRadioStations.isNotEmpty
              ? Expanded(
                  child: ListView(
                      children: searchedRadioStations.map((radio) {
                  return GFListTile(
                    enabled: true,
                    selected: true,
                    color: Colors.grey.shade50,
                    avatar: GFAvatar(
                        backgroundColor: Colors.white,
                        child: Image.network(radio.favicon!,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset("assets/music.jpg"))),
                    title: Text(radio.name!).text.bold.make(),
                    subTitle: Text(radio.country!),
                    icon: SizedBox(
                        width: 120,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FavoritesButton(station: radio),
                              PlayStopButton(
                                  stationId: radio.stationUuid!,
                                  stationList: searchedRadioStations),
                              FUI(RegularRounded.FILE_ADD,
                                  width: 20,
                                  height: 20,
                                  color: Color.fromARGB(255, 0, 29, 10)),
                              // FUI(SolidStraight.FORWARD, width: 30, height: 20, color: Colors.blueGrey)
                            ])),
                  );
                }).toList()))
              : Container()
        ]));
  }
}
