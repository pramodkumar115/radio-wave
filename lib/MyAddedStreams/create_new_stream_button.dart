import 'package:flutter/material.dart';
import 'package:orbit_radio/MyAddedStreams/create_edit_stream.dart';
import 'package:orbit_radio/model/radio_station.dart';

class CreateNewStreamButton extends StatefulWidget {
  const CreateNewStreamButton({super.key, required this.items});
  final List<RadioStation> items;
  @override
  State<CreateNewStreamButton> createState() => _CreateNewPlaylistButtonState();
}

class _CreateNewPlaylistButtonState extends State<CreateNewStreamButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      backgroundColor: Colors.redAccent,
      focusColor: Colors.green,
      onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.white,
          builder: (context) =>
              CreateEditStream(streams: widget.items, selected: null)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            Icon(
              Icons.add_box_rounded,
              color: Colors.white,
            ),
            Text(
              "Create New Stream",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            )
          ]),
    );
  }
}
