import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/components/create_new_playlist_button.dart';
import 'package:orbit_radio/components/playlist_tile.dart';
import 'package:orbit_radio/model/playlist_item.dart';

class MyPlaylistListView extends ConsumerStatefulWidget {
  const MyPlaylistListView({super.key});

  @override
  ConsumerState<MyPlaylistListView> createState() => _MyPlaylistListViewState();
}

class _MyPlaylistListViewState extends ConsumerState<MyPlaylistListView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.read(playlistDataProvider.notifier).build();
    final playListData = ref.watch(playlistDataProvider);
    debugPrint("favoritesUUIDs - $playListData");
    return playListData.when(data: (pListData) {
      setState(() {
        _isLoading = false;
      });
      return showContent(context, pListData);
    }, error: (error, stacktrace) {
      setState(() => setState(() => _isLoading = false));
      return Center(child: Text("Error getting data"));
    }, loading: () {
      setState(() => _isLoading = true);
      debugPrint("In loading");
      return CircularProgressIndicator();
    });
  }

  Widget showContent(
      BuildContext context, List<PlayListJsonItem> playlistJsonItems) {
    debugPrint('playlist length - ${playlistJsonItems.length}');
    return Container(
        margin: const EdgeInsets.only(top: 65),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20)),
        child: _isLoading
            ? ListView(children: [Center(child: Text("Please wait"))])
            : ListView(children: [
                CreateNewPlaylistButton(items: playlistJsonItems),
                ...getWidget(playlistJsonItems)
              ]));
  }

  List<Widget> getWidget(List<PlayListJsonItem> playlistJsonItems) {
    if (playlistJsonItems.isNotEmpty) {
      return playlistJsonItems
          .map((pl) => Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: PlaylistTile(
                  playlistJsonItems: playlistJsonItems, playlistJsonItem: pl)))
          .toList();
    } else {
      [Center(child: Text("No Playlists yet"))];
    }
    return [Container()];
  }
}
