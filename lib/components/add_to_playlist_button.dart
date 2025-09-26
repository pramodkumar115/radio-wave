import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:orbit_radio/components/add_to_playlist_popup.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';

class AddToPlaylistButton extends ConsumerStatefulWidget {
  const AddToPlaylistButton({super.key, required this.station});
  final RadioStation station;

  @override
  ConsumerState<AddToPlaylistButton> createState() =>
      _AddToPlaylistButtonState();
}

class _AddToPlaylistButtonState extends ConsumerState<AddToPlaylistButton> {
  List<PlayListJsonItem>? playlistDataItems;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: const FUI(RegularRounded.FILE_ADD,
            color: Color.fromRGBO(248, 1, 26, 1), width: 25, height: 25),
        onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.white,
            // backgroundColor: Colors.grey.shade100,
            builder: (context) =>
                AddToPlaylistPopup(selectedRadioStn: widget.station)));
  }
}
