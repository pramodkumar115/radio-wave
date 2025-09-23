import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/model/playlist_item.dart';

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
  int index = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selected != null) {
      setState(() {
        _nameController.text = widget.selected!.name;
        if (widget.selected != null) {
          setState(
              () => index = widget.playlistDataItems.indexOf(widget.selected!));
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void createPlayList(List<PlayListJsonItem> playlistDataItems) async {
    if (widget.selected != null) {
      playlistDataItems[index].name = _nameController.text;
    } else {
      playlistDataItems
          .add(PlayListJsonItem(name: _nameController.text, stationIds: []));
    }
    await ref
        .watch(playlistDataProvider.notifier)
        .updatePlayList(playlistDataItems);
    setState(() {
      _nameController.text = "";
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
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
                      border: OutlineInputBorder(), labelText: 'Playlist Name'),
                ),
                GFButton(
                    text: "Create / Save",
                    color: Colors.black,
                    fullWidthButton: true,
                    size: 60,
                    type: GFButtonType.solid,
                    shape: GFButtonShape.pills,
                    onPressed: () => createPlayList(widget.playlistDataItems))
              ],
            )));
  }
}
