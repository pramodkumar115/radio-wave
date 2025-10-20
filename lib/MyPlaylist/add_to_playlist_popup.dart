import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/MyPlaylist/create_new_playlist_button.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';

class AddToPlaylistPopup extends ConsumerStatefulWidget {
  const AddToPlaylistPopup(
      {super.key,
      // required this.playlistDataItems,
      required this.selectedRadioStn});
  // final List<PlayListJsonItem> playlistDataItems;
  final RadioStation selectedRadioStn;

  @override
  ConsumerState<AddToPlaylistPopup> createState() => _AddToPlaylistTileState();
}

class _AddToPlaylistTileState extends ConsumerState<AddToPlaylistPopup> {
  String selectedPlayListName = "";
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistData = ref.watch(playlistDataProvider);
    return playlistData.when(
        data: (items) {
          return showContent(items);
        },
        loading: () => showContent([]),
        error: (error, stackTrace) => Center(child: Text('Error: $error')));
  }

  Widget showContent(List<PlayListJsonItem> items) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.height;

    return SizedBox(
        height: screenHeight * 0.9,
        child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: screenWidth,
                    child: CreateNewPlaylistButton(items: items),
                  ),
                  Expanded(
                      child: ListView(children: [
                    ...items.map((item) => GFCheckboxListTile(
                        type: GFCheckboxType.circle,
                        color: Colors.white,
                        value: selectedPlayListName == item.name,
                        onChanged: (value) {
                          setState(() {
                            selectedPlayListName = item.name;
                          });
                        },
                        title: Text(item.name)))
                  ])),
                  selectedPlayListName.isNotEmpty
                      ? GFButton(
                          text: "Save",
                          fullWidthButton: true,
                          shape: GFButtonShape.pills,
                          onPressed: () async {
                            if (selectedPlayListName.isNotEmpty) {
                              // List<PlayListJsonItem> playListDataItems =
                              //    List.empty(growable: true);
                              // for (var i = 0; i < items.length; i++) {
                              //   var item = items[i];
                              //   if (item.name == selectedPlayListName) {
                              //     playListDataItems.add(PlayListJsonItem(
                              //         name: selectedPlayListName,
                              //         stationIds: [
                              //           widget.selectedRadioStn.stationUuid!,
                              //           ...item.stationIds
                              //         ]));
                              //   } else {
                              //     playListDataItems.add(item);
                              //   }
                              // }
                              var pl = items.firstWhereOrNull(
                                  (item) => item.name == selectedPlayListName);
                              if (pl != null) {
                                pl.stationIds
                                    .add(widget.selectedRadioStn.stationUuid!);
                                await ref
                                    .read(playlistDataProvider.notifier)
                                    .updatePlayList(items);
                                if (context.mounted) {
                                  GFToast.showToast(
                                      "Added to playlist", context);
                                  Navigator.pop(context);
                                }
                              }
                            }
                          })
                      : Container()
                ])));
  }
}
