import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile_list_reorderable_view.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';

class CreateEditPlaylist extends ConsumerStatefulWidget {
  const CreateEditPlaylist({super.key, required this.selectedPlayListId});
  final String? selectedPlayListId;

  @override
  ConsumerState<CreateEditPlaylist> createState() => _CreateEditPlaylistState();
}

class _CreateEditPlaylistState extends ConsumerState<CreateEditPlaylist> {
  final TextEditingController _nameController = TextEditingController();
  PlayListJsonItem? selectedPLaylist;
  List<RadioStation> selectedRadios = List.empty(growable: true);

  Future<PlayListItem?> loadPlayListStations(
      String playListId, List<PlayListJsonItem> playListJsonItems) async {
    if (playListJsonItems.isNotEmpty) {
      PlayListJsonItem? selected =
          playListJsonItems.firstWhereOrNull((e) => e.id == playListId);
      var stations = await getStationsListForUUIDs(selected!.stationIds);
      return PlayListItem(
          id: selected.id, name: selected.name, radioStations: stations);
    }
    return null;
  }

  void setSelectedRadios(List<RadioStation> radios) {
    print("radios - $radios");
    setState(() {
      selectedRadios = radios;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void createPlayList(List<PlayListJsonItem> playlistDataItems) async {
    if (_nameController.text.isEmpty) {
      GFToast.showToast("Please enter name of the playlist", context);
    } else {
      if (widget.selectedPlayListId != null) {
        PlayListJsonItem? selectedItem = playlistDataItems
            .firstWhereOrNull((e) => e.id == widget.selectedPlayListId);
        if (selectedItem != null) {
          selectedItem.name = _nameController.text;
        }
      } else {
        playlistDataItems.add(PlayListJsonItem(
            id: "PLAYLIST_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}",
            name: _nameController.text,
            stationIds: []));
      }
      await ref
          .watch(playlistDataProvider.notifier)
          .updatePlayList(playlistDataItems);
      setState(() {
        _nameController.text = "";
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final playListJsonItems = ref.watch(playlistDataProvider);
    return playListJsonItems.when(
      data: (items) => showContent(context, screenHeight, screenWidth, items),
      error: (error, stackTrace) => Center(child: Text("No PLaylist")),
      loading: () => CircularProgressIndicator(),
    );
  }

  SingleChildScrollView showContent(BuildContext context, double screenHeight,
      double screenWidth, List<PlayListJsonItem> items) {
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Adjust padding based on keyboard height
            ),
            child: SizedBox(
                height: screenHeight * 0.9,
                width: screenWidth,
                child: Container(
                    margin: EdgeInsets.all(24),
                    width: screenWidth,
                    child: FutureBuilder(
                        future: loadPlayListStations(
                            widget.selectedPlayListId!, items),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          } else {
                            PlayListItem playListItem = snapshot.data!;
                            _nameController.text = playListItem.name;
                            return Column(spacing: 20, children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Playlist Name'),
                              ),
                              Expanded(
                                  child: RadioTileListReorderableView(
                                      radioStationList:
                                          playListItem.radioStations,
                                      selectedRadios: selectedRadios,
                                      setSelectedRadios: setSelectedRadios)),
                              Row(spacing: 10, children: [
                                selectedRadios.isNotEmpty
                                    ? GFButton(
                                        text: "Delete",
                                        color: Colors.black,
                                        // fullWidthButton: true,
                                        size: 40,
                                        type: GFButtonType.outline,
                                        shape: GFButtonShape.pills,
                                        onPressed: () =>
                                            deleteStation(playListItem, items))
                                    : Container(),
                                GFButton(
                                    text: "Save",
                                    color: Colors.black,
                                    size: 40,
                                    type: GFButtonType.solid,
                                    shape: GFButtonShape.pills,
                                    onPressed: () => save(playListItem, items))
                              ])
                            ]);
                          }
                        })))));
  }

  void deleteStation(PlayListItem playListItem, List<PlayListJsonItem> items) {
    if (playListItem.radioStations.isNotEmpty) {
      PlayListJsonItem? selected =
          items.firstWhereOrNull((e) => e.id == playListItem.id);
      var selectedRadiosIdsToDelete = selectedRadios.map((e) => e.stationUuid);

      // selected!.stationIds = playListItem.radioStations
      //     .where((element) => !selectedRadios.contains(element))
      //     .map((element) => element.stationUuid!)
      //     .toList();
      selected!.stationIds = selected!.stationIds
          .where((element) => !selectedRadiosIdsToDelete.contains(element))
          .toList();
    }
    ref.watch(playlistDataProvider.notifier).updatePlayList(items);
  }

  void save(PlayListItem playListItem, List<PlayListJsonItem> items) {
    print(jsonEncode(playListItem.radioStations));
    if (playListItem.radioStations.isNotEmpty) {
      PlayListJsonItem? selected =
          items.firstWhereOrNull((e) => e.id == playListItem.id);
      print("--------------------------");
      print(jsonEncode(selected));
      print("--------------------------");

      if (selected != null) {
        selected.stationIds =
            playListItem.radioStations.map((e) => e.stationUuid!).toList();
      }
    }
    print(jsonEncode(items));
    createPlayList(items);
  }
}
