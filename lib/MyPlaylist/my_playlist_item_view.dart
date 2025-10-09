import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/Search/search_view.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/create_edit_playlist.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';

class MyPlaylistItemView extends ConsumerStatefulWidget {
  const MyPlaylistItemView({super.key, required this.selectedPlaylistId});

  final String selectedPlaylistId;

  @override
  ConsumerState<MyPlaylistItemView> createState() => _MyPlaylistItemViewState();
}

class _MyPlaylistItemViewState extends ConsumerState<MyPlaylistItemView> {
  PlayListItem? playListItem;

  @override
  void initState() {
    super.initState();
  }

  Future<List<RadioStation>> getStations(
      PlayListJsonItem? playlistJsonItem) async {
    List<RadioStation> returnable = List.empty(growable: true);
    if (playlistJsonItem != null) {
      var stationsIds = playlistJsonItem.stationIds;
      List<RadioStation> aList = await getAddedStreamsFromFile();
      for (var id in stationsIds) {
        if (id.startsWith("ADDED")) {
          returnable.add(aList.firstWhere((e) => e.stationUuid == id));
        } else {
          returnable.addAll(await getStationsListForUUIDs([id]));
        }
      }
    }
    return returnable;
  }

  @override
  Widget build(BuildContext context) {
    final playlistItems = ref.watch(playlistDataProvider);
    return playlistItems.when(
        data: (items) {
          if (items != null && items.isNotEmpty) {
            var playlistJsonItem = items
                .firstWhereOrNull((e) => e.id == widget.selectedPlaylistId);
            return showContent(playlistJsonItem, items);
          }
          return Center(
              child: Text(
                  "Please add the radio stations from search/favorites or home page"));
        },
        loading: () => CircularProgressIndicator(),
        error: (error, stackTrace) => Center(child: Text('Error: $error')));
  }

  void _showConfirmationDialog(BuildContext context,
      List<PlayListJsonItem> items, PlayListJsonItem playListJsonItem) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Delete playlist'),
          content: Text('Are you sure you want to delete the playlist?'),
          actions: <Widget>[
            GFButton(
              type: GFButtonType.outline,
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User canceled
              },
              child: Text('Cancel'),
            ),
            GFButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User confirmed
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    ).then((confirmed) async {
      if (confirmed != null && confirmed) {
        var filtered = items
            .where((element) => element.id != playListJsonItem!.id)
            .toList();
        await ref.watch(playlistDataProvider.notifier).updatePlayList(filtered);
        Navigator.pop(context);
      } else {
        print('Action canceled or dialog dismissed.');
      }
    });
  }

  Widget showContent(PlayListJsonItem? playListJsonItem,
      List<PlayListJsonItem> playlistJsonItems) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              Container(
                  padding: EdgeInsets.only(right: 20),
                  child: GestureDetector(
                      child: Icon(Icons.delete_forever),
                      onTap: () {
                        _showConfirmationDialog(
                            context, playlistJsonItems, playListJsonItem!);
                      })),
              Container(
                  padding: EdgeInsets.only(right: 20),
                  child: GestureDetector(
                      child: Icon(Icons.edit_square),
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            isDismissible: true,
                            backgroundColor: Colors.white,
                            builder: (context) => CreateEditPlaylist(
                                playlistDataItems: playlistJsonItems,
                                selected: playListJsonItem));
                      }))
            ],
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    "Playlist - ${playListJsonItem != null ? playListJsonItem.name : ""}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            )),
        body: FutureBuilder(
            future: getStations(playListJsonItem),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var radioStations = snapshot.data;
                return Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(
                          'assets/backgroundNewPage.jpg'), // Your image path
                      fit: BoxFit
                          .cover, // Adjust how the image fits the container
                    )),
                    child: radioStations != null && radioStations.isNotEmpty
                        ? Column(children: [
                            Expanded(
                                child: ListView(
                                    children: radioStations.map((radio) {
                              return RadioTile(
                                  radio: radio,
                                  radioStations: radioStations,
                                  from: 'PLAYLIST|${playListJsonItem!.name}',
                                  isReorderClicked: false);
                            }).toList()))
                          ])
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text("No Radio Stations added."),
                            GFButton(
                                text: "Search Radio Stations",
                                type: GFButtonType.solid,
                                icon: const Icon(Icons.search,
                                    color: Colors.white, size: 20),
                                color: Colors.blueGrey,
                                fullWidthButton: true,
                                shape: GFButtonShape.pills,
                                onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                          builder: (context) =>
                                              const SearchView()),
                                    ))
                          ])));
              } else {
                return GFShimmer(child: emptyCardBlock);
              }
            }));
  }
}
