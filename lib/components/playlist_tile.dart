import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/MyPlaylist/my_playlist_item_view.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/model/playlist_item.dart';

class PlaylistTile extends ConsumerStatefulWidget {
  const PlaylistTile({super.key, required this.selectedPlaylistId});
  final String selectedPlaylistId;

  @override
  ConsumerState<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends ConsumerState<PlaylistTile> {
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(playlistDataProvider);
    return items.when(
        data: (items) {
          return showContent(items);
        },
        loading: () => showContent([]),
        error: (error, stackTrace) => Center(child: Text('Error: $error')));
  }

  Widget showContent(List<PlayListJsonItem> playlistJsonItems) {
    var playlistJsonItem = playlistJsonItems
        .firstWhere((e) => e.id == widget.selectedPlaylistId);
    return GestureDetector(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(playlistJsonItem.name,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right_outlined)
                      ])),
              Divider()
            ]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (context) => MyPlaylistItemView(
                    selectedPlaylistId: widget.selectedPlaylistId)),
          );
        });
  }

  // void removeSelectedPlaylist() {
  //   var playListAsync = ref.watch(playlistDataProvider);
  //   playListAsync.when(
  //       data: (dataSet) {
  //         ref.read(playlistDataProvider.notifier).updatePlayList(dataSet
  //             .where((d) => d.name != widget.playlistJsonItem.name)
  //             .toList());
  //       },
  //       error: (error, stackTrace) => Center(child: Text('Error: $error')),
  //       loading: () {});
  // }
}
