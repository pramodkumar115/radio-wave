
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
  const CreateEditPlaylist(
      {super.key, required this.playlistDataItems, required this.selected});
  final List<PlayListJsonItem> playlistDataItems;
  final PlayListJsonItem? selected;

  @override
  ConsumerState<CreateEditPlaylist> createState() => _CreateEditPlaylistState();
}

class _CreateEditPlaylistState extends ConsumerState<CreateEditPlaylist> {
  final TextEditingController _nameController = TextEditingController();
  String playListId = "";
  List<RadioStation> playListStations = List.empty(growable: true);
  List<RadioStation> selectedRadios = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      loadPlayListStations();
      setState(() {
        _nameController.text = widget.selected!.name;
        // index = widget.playlistDataItems.indexOf(widget.selected!);
      });
    }
  }

  Future<void> loadPlayListStations() async {
    var stations = await getStationsListForUUIDs(widget.selected!.stationIds);
    setState(() {
      playListStations.addAll(stations);
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
      if (widget.selected != null) {
        var index = playlistDataItems.indexOf(widget.selected!);
        playlistDataItems[index].name = _nameController.text;
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

    // PlayListJsonItem currentPlayListItem = widget.playlistDataItems[index];

    return SingleChildScrollView(
        // Make the content scrollable
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
                    child: Column(
                      spacing: 20,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Playlist Name'),
                        ),
                        Expanded(
                            child: RadioTileListReorderableView(
                                radioStationList: playListStations,
                                selectedRadios: selectedRadios)),
                        Row(spacing: 10, children: [
                          widget.selected != null
                              ? GFButton(
                                  text: "Delete",
                                  color: Colors.black,
                                  // fullWidthButton: true,
                                  size: 40,
                                  type: GFButtonType.outline,
                                  shape: GFButtonShape.pills,
                                  onPressed: () {
                                    if (playListStations.isNotEmpty &&
                                        widget.selected != null) {
                                      var index = widget.playlistDataItems
                                          .indexOf(widget.selected!);
                                      widget.playlistDataItems[index]
                                              .stationIds =
                                          playListStations
                                              .where((element) =>
                                                  !selectedRadios
                                                      .contains(element))
                                              .map((element) =>
                                                  element.stationUuid!)
                                              .toList();
                                    }
                                    ref
                                        .watch(playlistDataProvider.notifier)
                                        .updatePlayList(
                                            widget.playlistDataItems);
                                  })
                              : Container(),
                          GFButton(
                              text: "Save",
                              color: Colors.black,
                              // fullWidthButton: true,
                              size: 40,
                              type: GFButtonType.solid,
                              shape: GFButtonShape.pills,
                              onPressed: () {
                                if (playListStations.isNotEmpty &&
                                    widget.selected != null) {
                                  var index = widget.playlistDataItems
                                      .indexOf(widget.selected!);
                                  widget.playlistDataItems[index].stationIds =
                                      playListStations
                                          .map((e) => e.stationUuid!)
                                          .toList();
                                }
                                createPlayList(widget.playlistDataItems);
                              })
                        ])
                      ],
                    )))));
  }
}
