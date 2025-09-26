import 'package:flutter/material.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:orbit_radio/components/create_edit_playlist.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:velocity_x/velocity_x.dart';

class CreateNewPlaylistButton extends StatefulWidget {
  const CreateNewPlaylistButton({super.key, required this.items});
  final List<PlayListJsonItem> items;
  @override
  State<CreateNewPlaylistButton> createState() =>
      _CreateNewPlaylistButtonState();
}

class _CreateNewPlaylistButtonState extends State<CreateNewPlaylistButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
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
          ]
          )
        ),
        onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.white,
            builder: (context) =>  CreateEditPlaylist(
                    playlistDataItems: widget.items, selected: null)));
  }
}
