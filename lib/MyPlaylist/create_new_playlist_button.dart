import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:orbit_radio/MyPlaylist/create_edit_playlist.dart';
import 'package:orbit_radio/model/playlist_item.dart';

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
    // return GestureDetector(
    //     child: Container(
    //         padding: EdgeInsets.all(15),
    //         child: Row(spacing: 10, children: [
    //           Icon(
    //             Icons.add_circle,
    //             color: Colors.red,
    //           ),
    //           Text(
    //             "Create New Playlist",
    //             style: TextStyle(
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.bold,
    //                 color: Colors.red),
    //           )
    //         ])),
    //     onTap: () => showModalBottomSheet(
    //         context: context,
    //         isScrollControlled: true,
    //         isDismissible: true,
    //         backgroundColor: Colors.white,
    //         builder: (context) => CreateEditPlaylist(selectedPlayListId: null)));
    return FloatingActionButton.small(
      backgroundColor: Colors.redAccent,
      focusColor: Colors.green,
      onPressed: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.white,
            builder: (context) => CreateEditPlaylist(selectedPlayListId: null));
      },
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            Icon(
              Icons.add_box_rounded,
              color: Colors.white,
            ),
            Text(
              "Add New Playlist",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            )
          ]),
    );
  }
}
