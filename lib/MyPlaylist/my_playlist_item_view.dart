import 'package:flutter/material.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class MyPlaylistItemView extends StatefulWidget {
  const MyPlaylistItemView({super.key, required this.playListJsonItem});
  final PlayListJsonItem playListJsonItem;

  @override
  State<MyPlaylistItemView> createState() => _MyPlaylistItemViewState();
}

class _MyPlaylistItemViewState extends State<MyPlaylistItemView> {
  PlayListItem? playListItem;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var addedStreamIds = widget.playListJsonItem.stationIds
        .where((s) => s.startsWith("ADDED"))
        .toList();
    List<RadioStation> stations =
        await getStationsListForUUIDs(widget.playListJsonItem.stationIds);
    final aList = await getAddedStreamsFromFile();
    final addedList =
        aList.where((a) => addedStreamIds.contains(a.stationUuid)).toList();

    print("stations size - ${stations.length}");
    setState(() {
      playListItem = PlayListItem(
          name: widget.playListJsonItem.name,
          radioStations: [...stations, ...addedList]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Playlist - ${playListItem!.name}")
                .text
                .bold
                .xl
                .make(),
          ],
        )),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image:
                  AssetImage('assets/backgroundNewPage.jpg'), // Your image path
              fit: BoxFit.cover, // Adjust how the image fits the container
            )),
            child: playListItem?.radioStations != null
                ? Column(children: [
                    Expanded(
                        child: ListView(
                            children: playListItem!.radioStations.map((radio) {
                      return RadioTile(
                          radio: radio,
                          radioStations: playListItem!.radioStations,
                          isAddedStream: false);
                    }).toList()))
                  ])
                : Center(child: Text("No Radio Stations added"))));
  }
}
