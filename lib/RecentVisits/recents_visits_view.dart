import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/RecentVisitsAll/recents_visits_all_view.dart';
import 'package:orbit_radio/Search/search_view.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';

class RecentVisitsView extends ConsumerStatefulWidget {
  const RecentVisitsView({super.key});
  @override
  ConsumerState<RecentVisitsView> createState() => _RecentVisitsViewState();
}

class _RecentVisitsViewState extends ConsumerState<RecentVisitsView> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<RadioStation>> loadData() async {
    List<String> uuids = await getRecentVisitsFromFile();
    return await getStationsListForUUIDs(uuids);
  }

  @override
  Widget build(BuildContext context) {
    print("In recent");

    return FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return showContent(snapshot.data);
          } else {
            return GFShimmer(child: emptyCardBlock);
          }
        });
  }

  Widget showContent(List<RadioStation>? stationList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Recent Visits",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
        GestureDetector(
            child: Text("View All",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (context) => RecentsVisitsAllView()));
            })
      ]),
      stationList != null && stationList.isNotEmpty
          ? // RadioStationListView(stationList: stationList)
          SizedBox(
              height: 300,
              child: ListView(
                  children: stationList
                      .sublist(
                          0, stationList.length > 4 ? 4 : stationList.length)
                      .map((radio) {
                return RadioTile(
                    radio: radio,
                    radioStations: stationList,
                    from: 'RECENT_VISITS');
              }).toList()))
          : Container(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Text("No history of radios yet",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
                GFButton(
                    text: "Search Radio Stations",
                    type: GFButtonType.solid,
                    icon:
                        const Icon(Icons.search, color: Colors.white, size: 20),
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
