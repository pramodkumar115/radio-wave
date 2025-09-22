import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:popover/popover.dart';
import 'package:velocity_x/velocity_x.dart';

class AddToPlaylistButton extends ConsumerStatefulWidget {
  const AddToPlaylistButton({super.key, required this.station});
  final RadioStation station;

  @override
  ConsumerState<AddToPlaylistButton> createState() =>
      _AddToPlaylistButtonState();
}

class _AddToPlaylistButtonState extends ConsumerState<AddToPlaylistButton> {
  String? selectedPlayListItem;
  final TextEditingController _nameController = TextEditingController();

  Future<void> addToFavorites(
      List<String> favoritesUUIDs, selectedRadioStation) async {
    var message = "";
    if (!favoritesUUIDs.contains(selectedRadioStation!.stationUuid!)) {
      favoritesUUIDs = [...favoritesUUIDs, selectedRadioStation!.stationUuid!];
      message = 'Station added to favorites';
    } else {
      favoritesUUIDs = favoritesUUIDs
          .where((element) => element != selectedRadioStation!.stationUuid!)
          .toList();
      message = 'Station removed from favorites';
    }
    ref.read(favoritesDataProvider.notifier).updateFavorites(favoritesUUIDs);
    GFToast.showToast(message, context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistData = ref.watch(playlistDataProvider);
    return playlistData.when(
        data: (playlistDataItems) {
          return showContent(playlistDataItems, widget.station);
        },
        loading: () => showContent([], widget.station),
        error: (error, stackTrace) => Center(child: Text('Error: $error')));
  }

  void createPlayList(List<PlayListJsonItem> playlistDataItems) async {
    playlistDataItems
        .add(PlayListJsonItem(name: _nameController.text, stationIds: []));
    await ref
        .watch(playlistDataProvider.notifier)
        .updatePlayList(playlistDataItems);
    ref.watch(playlistDataProvider.notifier).build();
    setState(() {
      _nameController.text = "";
    });
    Navigator.pop(context);
  }

  Widget showContent(
      List<PlayListJsonItem> playlistDataItems, RadioStation station) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
        child: const FUI(
          RegularRounded.FILE_ADD,
          color: Color.fromRGBO(248, 1, 26, 1),
        ),
        onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.white,
            // backgroundColor: Colors.grey.shade100,
            builder: (context) => SizedBox(
                height: screenHeight * 0.9,
                child: Container(
                    margin: EdgeInsets.all(24),
                    child: Column(spacing: 10, children: [
                      SizedBox(height: 20),
                      GestureDetector(
                          child: Row(
                            spacing: 10,
                            children: [
                              FUI(
                                RegularRounded.ADD,
                                color: Colors.red,
                              ),
                              Text(
                                "Create New Playlist",
                              ).text.bold.xl.red600.make()
                            ],
                          ),
                          onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: true,
                              backgroundColor: Colors.white,
                              builder: (context) => SizedBox(
                                  height: screenHeight * 0.5,
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
                                          GFButton(
                                              text: "Create",
                                              color: Colors.black,
                                              fullWidthButton: true,
                                              size: 60,
                                              type: GFButtonType.solid,
                                              shape: GFButtonShape.pills,
                                              onPressed: () => createPlayList(
                                                  playlistDataItems))
                                        ],
                                      ))))),
                      Expanded(
                          child: ListView(children: [
                        ...playlistDataItems.map((item) => GFCheckboxListTile(
                            value: true,
                            onChanged: (value) {},
                            title: Text(item.name)))
                      ]))
                    ])))));
  }
}



/* 
showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
                  child: ListView(
                  children: playlistDataItem
                      .map(
                        (e) => GFCheckboxListTile(
                          titleText: e.name,
                          // subTitleText: 'By order of the peaky blinders',
                          // avatar: GFAvatar(
                          //   backgroundImage: AssetImage('Assets image here'),
                          // ),
                          size: 25,
                          activeBgColor: Colors.green,
                          type: GFCheckboxType.circle,
                          activeIcon: Icon(
                            Icons.check,
                            size: 15,
                            color: Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() {
                              // selectedPlayListItem = value;
                            });
                          },
                          value: selectedPlayListItem == '',
                          inactiveIcon: null,
                        ),
                      )
                      .toList(),
                ),
                // Row(children: [
                //   GFButton(
                //     onPressed: () {},
                //     text: "Add to playlist",
                //   ),
                //   GFButton(
                //     onPressed: () {},
                //     text: "Create New Playlist",
                //   ),
                // ])
              )
              ), */