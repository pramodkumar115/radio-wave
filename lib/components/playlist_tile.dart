import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/MyPlaylist/my_playlist_item_view.dart';
import 'package:orbit_radio/Notifiers/playing_radio_details_provider.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/components/create_edit_playlist.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:velocity_x/velocity_x.dart';

class PlaylistTile extends ConsumerStatefulWidget {
  const PlaylistTile(
      {super.key,
      required this.playlistJsonItem,
      required this.playlistJsonItems});
  final PlayListJsonItem playlistJsonItem;
  final List<PlayListJsonItem> playlistJsonItems;

  @override
  ConsumerState<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends ConsumerState<PlaylistTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: GFListTile(
          enabled: true,
          selected: true,
          color: Colors.grey.shade50,
          title: Text(widget.playlistJsonItem.name).text.bold.make(),
          icon: SizedBox(
              width: 80,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 20,
                  children: [
                    GestureDetector(
                        child: FUI(RegularRounded.TRASH,
                            color: Colors.black, width: 25, height: 25),
                        onTap: () => removeSelectedPlaylist()),
                    GestureDetector(
                        child: FUI(RegularRounded.EDIT,
                            color: Colors.black, width: 25, height: 25),
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: true,
                              backgroundColor: Colors.white,
                              builder: (context) => CreateEditPlaylist(
                                  playlistDataItems: widget.playlistJsonItems,
                                  selected: widget.playlistJsonItem));
                        })
                  ])),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (context) => MyPlaylistItemView(
                    playListJsonItem: widget.playlistJsonItem)),
          );
        });
  }

  void removeSelectedPlaylist() {
    var playListAsync = ref.watch(playlistDataProvider);
    playListAsync.when(
        data: (dataSet) {
          ref.read(playlistDataProvider.notifier).updatePlayList(dataSet
              .where((d) => d.name != widget.playlistJsonItem.name)
              .toList());
        },
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () {});
  }
}
