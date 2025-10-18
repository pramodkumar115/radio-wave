import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
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
  Future<PlayListItem?> loadPlayListStations(
      String? playListId, List<PlayListJsonItem> playListJsonItems) async {
    if (playListId != null && playListJsonItems.isNotEmpty) {
      PlayListJsonItem? selected =
          playListJsonItems.firstWhereOrNull((e) => e.id == playListId);
      var stations = await getStationsListForUUIDs(selected!.stationIds);
      return PlayListItem(
          id: selected.id, name: selected.name, radioStations: stations);
    }
    return null;
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
              bottom: widget.selectedPlayListId == null
                  ? MediaQuery.of(context).viewInsets.bottom
                  : 0, // Adjust padding based on keyboard height
            ),
            child: SizedBox(
                height: widget.selectedPlayListId != null
                    ? screenHeight * 0.9
                    : screenHeight * 0.5,
                width: screenWidth,
                child: Container(
                    margin: EdgeInsets.all(24),
                    width: screenWidth,
                    child: FutureBuilder(
                        future: loadPlayListStations(
                            widget.selectedPlayListId, items),
                        builder: (context, snapshot) {
                          return Skeleton(
                              isLoading: snapshot.connectionState ==
                                  ConnectionState.waiting,
                              skeleton: SkeletonListView(),
                              child: EditCreatePlayListWidget(
                                  playListItem: snapshot.data,
                                  items: items,
                                  context: context));
                        })))));
  }
}

class EditCreatePlayListWidget extends ConsumerStatefulWidget {
  const EditCreatePlayListWidget(
      {super.key,
      required this.playListItem,
      required this.items,
      required this.context});
  final PlayListItem? playListItem;
  final List<PlayListJsonItem> items;
  final BuildContext context;

  @override
  ConsumerState<EditCreatePlayListWidget> createState() =>
      _EditCreatePlayListWidgetState();
}

class _EditCreatePlayListWidgetState
    extends ConsumerState<EditCreatePlayListWidget> {
  late TextEditingController _nameController;
  List<RadioStation> selectedRadios = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    print("widget.playListItem - ${widget.playListItem}");
    if (widget.playListItem != null) {
      _nameController = TextEditingController(text: widget.playListItem?.name);
    } else {
      _nameController = TextEditingController();
    }
  }

  void createPlayList(List<PlayListJsonItem> playlistDataItems) async {
    if (_nameController.text.isEmpty) {
      GFToast.showToast("Please enter name of the playlist", context);
    } else {
      if (widget.playListItem != null) {
        PlayListJsonItem? selectedItem = playlistDataItems
            .firstWhereOrNull((e) => e.id == widget.playListItem?.id);
        if (selectedItem != null) {
          selectedItem.name = _nameController.text;
        }
      } else {
        playlistDataItems.add(PlayListJsonItem(
            id: "PLAYLIST_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}",
            name: _nameController.text,
            stationIds: []));
      }
      if (widget.context != null && widget.context.mounted) {
        Navigator.pop(widget.context);
      }
      await ref
          .watch(playlistDataProvider.notifier)
          .updatePlayList(playlistDataItems);
    }
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

  void deleteStation(PlayListItem? playListItem, List<PlayListJsonItem> items) {
    if (playListItem != null && playListItem.radioStations.isNotEmpty) {
      PlayListJsonItem? selected =
          items.firstWhereOrNull((e) => e.id == playListItem.id);
      var selectedRadiosIdsToDelete = selectedRadios.map((e) => e.stationUuid);
      selected!.stationIds = selected.stationIds
          .where((element) => !selectedRadiosIdsToDelete.contains(element))
          .toList();
    }
    ref.watch(playlistDataProvider.notifier).updatePlayList(items);
  }

  void save(PlayListItem? playListItem, List<PlayListJsonItem> items) {
    if (playListItem != null && playListItem.radioStations.isNotEmpty) {
      PlayListJsonItem? selected =
          items.firstWhereOrNull((e) => e.id == playListItem.id);
      if (selected != null) {
        selected.stationIds =
            playListItem.radioStations.map((e) => e.stationUuid!).toList();
      }
    }

    createPlayList(items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(spacing: 20, children: [
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), labelText: 'Playlist Name'),
      ),
      widget.playListItem != null
          ? Expanded(
              child: RadioTileListReorderableView(
                  radioStationList: widget.playListItem!.radioStations,
                  selectedRadios: selectedRadios,
                  setSelectedRadios: setSelectedRadios,
                  showCheckBox: true))
          : Container(),
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
                    deleteStation(widget.playListItem, widget.items))
            : Container(),
        GFButton(
            text: "Save",
            color: Colors.black,
            size: 40,
            type: GFButtonType.solid,
            shape: GFButtonShape.pills,
            onPressed: () => save(widget.playListItem, widget.items))
      ])
    ]);
  }
}
