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
    return GestureDetector(
        child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            // margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              spacing: 10,
              children: [
                Icon(
                  Icons.add_circle,
                  color: Colors.red,
                ),
                Text(
                "Create New Stream",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              )
              ],
            )),
        onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.white,
            builder: (context) =>
                CreateEditStream(streams: widget.items, selected: null)));
  }
}
