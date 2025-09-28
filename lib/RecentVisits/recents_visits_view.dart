import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/recent_visits_notifier.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/RecentVisitsAll/recents_visits_all_view.dart';
import 'package:orbit_radio/Search/search_view.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class RecentVisitsView extends ConsumerStatefulWidget {
  const RecentVisitsView({super.key});
  @override
  ConsumerState<RecentVisitsView> createState() => _RecentVisitsViewState();
}

class _RecentVisitsViewState extends ConsumerState<RecentVisitsView> {
  List<RadioStation> stationList = List.empty(growable: true);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });
    List<String> uuids = await getRecentVisitsFromFile();
    List<RadioStation> stnList = await getStationsListForUUIDs(uuids);
    setState(() {
      stationList = stnList;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("In recent");
    return VStack([
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Recent Visits").text.scale(1.1).bold.make(),
        GestureDetector(
            child: Text("View All").text.bold.underline.make(),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (context) =>
                          RecentsVisitsAllView(stationsList: stationList)));
            })
      ]),
      _isLoading
          ? GFShimmer(child: emptyCardBlock)
          : stationList.isNotEmpty
              ? // RadioStationListView(stationList: stationList)
              SizedBox(
                  height: 300,
                  child: ListView(
                      children: stationList.sublist(0, 4).map((radio) {
                    return RadioTile(
                        radio: radio,
                        radioStations: stationList,
                        from: 'RECENT_VISITS');
                  }).toList()))
              : Container(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    Text("No history of radios yet").text.bold.make(),
                    GFButton(
                        text: "Search Radio Stations",
                        type: GFButtonType.solid,
                        icon: FUI(BoldRounded.SEARCH,
                            color: Colors.white, width: 20, height: 20),
                        color: Colors.blueGrey,
                        fullWidthButton: true,
                        shape: GFButtonShape.pills,
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) => const SearchView()),
                            ))
                  ]))
    ]);
  }
}
