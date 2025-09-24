import 'package:flutter/material.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:orbit_radio/components/create_edit_playlist.dart';
import 'package:orbit_radio/components/create_edit_stream.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class CreateNewStreamButton extends StatefulWidget {
  const CreateNewStreamButton({super.key, required this.items});
  final List<RadioStation> items;
  @override
  State<CreateNewStreamButton> createState() =>
      _CreateNewPlaylistButtonState();
}

class _CreateNewPlaylistButtonState extends State<CreateNewStreamButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Row(
          spacing: 10,
          children: [
            FUI(
              RegularRounded.ADD,
              color: Colors.red,
            ),
            Text(
              "Create New Stream",
            ).text.bold.xl.red600.make()
          ],
        ),
        onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.white,
            builder: (context) => CreateEditStream(
                streams: widget.items, selected: null)));
  }
}
