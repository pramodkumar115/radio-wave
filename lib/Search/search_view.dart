import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Search/search_service.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  int offset = 0, limit = 10;
  List<RadioStation> searchedRadioStations = List.empty(growable: true);
  Set<String> searchBy = {'byname'};
  String searchType = "ADVANCED";
  Timer? _debounce;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  List<String> countryList = List.empty(growable: true);
  String selectedCountry = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => loadData(offset, limit));
    _nameController.addListener(() => loadData(offset, limit));
    _countryController.addListener(() => loadData(offset, limit));
    _languageController.addListener(() => loadData(offset, limit));
    _tagController.addListener(() => loadData(offset, limit));
    getCountryList("").then((valueList) => setState(() {
          countryList = valueList;
        }));
  }

  List<String> filterCountryList(String search) {
    return countryList
        .where((e) => e.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  void loadData(int startIndex, int endIndex) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      setState(() {
        searchedRadioStations = [];
      });
      // String text = _searchController.text;
      // var response = searchType == 'SIMPLE'
      // ? await getSearchResults(
      // text.trim(), searchBy.first, startIndex, endIndex)
      // :
      if (_nameController.text.length > 3 ||
          selectedCountry.isNotEmpty ||
          _languageController.text.length > 3 ||
          _tagController.text.length > 3) {
        var response = await getAdvancedSearchResults(
            _nameController.text,
            selectedCountry,
            _languageController.text,
            _tagController.text,
            startIndex,
            endIndex);
        if (response != null &&
            response.statusCode == 200 &&
            response.body != null) {
          List<dynamic> stationList = jsonDecode(response.body);
          var list = stationList.map((d) => RadioStation.fromJson(d)).toList();
          // print("list - ${response.body}");
          setState(() {
            searchedRadioStations.clear();
            searchedRadioStations.addAll(list);
          });
        } else {
          throw Exception('Failed to load album');
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(() => loadData);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal.shade50,
        appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text("Search",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          //backgroundColor: Colors.grey.shade100,
        ),
        body: Column(children: [
          // Row(
          //   spacing: 10,
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     GFButton(
          //         onPressed: () {
          //           setState(() {
          //             searchType = 'SIMPLE';
          //             searchedRadioStations.clear();
          //           });
          //         },
          //         text: "Simple Search",
          //         color: const Color.fromARGB(255, 0, 75, 32),
          //         shape: GFButtonShape.pills,
          //         type: searchType == 'SIMPLE'
          //             ? GFButtonType.solid
          //             : GFButtonType.outline),
          //     GFButton(
          //         onPressed: () async {
          //           setState(() {
          //             searchType = 'ADVANCED';
          //             searchedRadioStations.clear();
          //           });
          //         },
          //         text: "Advanced Search",
          //         color: const Color.fromARGB(255, 0, 75, 32),
          //         shape: GFButtonShape.pills,
          //         type: searchType == 'ADVANCED'
          //             ? GFButtonType.solid
          //             : GFButtonType.outline)
          //   ],
          // ),
          searchType == 'SIMPLE'
              ? Column(children: [
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
                        ButtonSegment(
                            value: 'bycountry', label: Text('By Country')),
                        ButtonSegment(
                            value: 'bytag', label: Text('By Hashtag')),
                        ButtonSegment(
                            value: 'bylanguage', label: Text('By Language')),
                      ],
                      selected: searchBy,
                      onSelectionChanged: (Set<String> value) {
                        setState(() {
                          searchBy = value;
                          searchedRadioStations.clear();
                        });
                        Future.delayed(Duration.zero, () async {
                          if (_searchController.text.length >= 3) {
                            getData();
                          }
                        });
                      }),
                  TextField(
                    enableSuggestions: false,
                    textInputAction: TextInputAction.search,
                    controller: _searchController,
                    decoration: const InputDecoration(
                        labelText:
                            'Enter station name, country, language, tags etc'),
                  )
                ])
              : Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    spacing: 10,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name of the station'),
                      ),
                      TypeAheadField<String>(
                        suggestionsCallback: (search) =>
                            filterCountryList(search),
                        controller: _countryController,
                        builder: (context, controller, focusNode) {
                          return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              autofocus: false,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Country'));
                        },
                        itemBuilder: (context, country) {
                          return ListTile(title: Text(country));
                        },
                        onSelected: (country) {
                          setState(() {
                            selectedCountry = country;
                          });
                          _countryController.text = country;
                          // loadData(0, 10);
                        },
                      ),
                      TextField(
                        controller: _languageController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Language'),
                      ),
                      TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText:
                                'Hash Tags (Comma Seperated for multiple tag search)'),
                      ),
                    ],
                  )),
          Expanded(
                  child: ListView(children: [
                  ...searchedRadioStations.map((radio) {
                    return RadioTile(
                        radio: radio,
                        radioStations: searchedRadioStations,
                        from: "SEARCH",
                        isReorderClicked: false);
                  }),
                  Padding(
                      padding: EdgeInsetsGeometry.all(20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            offset >= 10
                                ? GFButton(
                                    type: GFButtonType.transparent,
                                    text: 'Previous',
                                    textColor: Colors.black,
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      loadData(offset - 10, limit);
                                      setState(() {
                                        offset = offset - 10;
                                      });
                                    })
                                : Container(),
                            searchedRadioStations.length >= 10
                                ? GFButton(
                                    type: GFButtonType.transparent,
                                    text: 'Next',
                                    icon: Icon(Icons.arrow_forward),
                                    textColor: Colors.black,
                                    onPressed: () {
                                      loadData(offset + 10, limit);
                                      setState(() {
                                        offset = offset + 10;
                                      });
                                    })
                                : Container(),
                          ]))
                ]))
              ,
        ]));
  }

  void getData() {
    loadData(0, 10);
    setState(() {
      offset = 0;
    });
  }
}
