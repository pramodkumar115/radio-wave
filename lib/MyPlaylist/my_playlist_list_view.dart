import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/create_new_playlist_button.dart';
import 'package:orbit_radio/components/playlist_tile.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

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
    print("favoritesUUIDs - $playListData");
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
      print("In loading");
      return CircularProgressIndicator();
    });
  }

  Widget showContent(
      BuildContext context, List<PlayListJsonItem> playlistJsonItems) {
    final double screenHeight = MediaQuery.of(context).size.height;
    print('playlist length - ${playlistJsonItems.length}');
    return Container(
            margin: const EdgeInsets.only(top: 50),
            child: _isLoading
                ? ListView(children: [Center(child: Text("Please wait"))])
                : ListView(children: [
                    CreateNewPlaylistButton(items: playlistJsonItems),
                    ...getWidget(playlistJsonItems)
                  ]))
        .p12();
  }

  List<Widget> getWidget(List<PlayListJsonItem> playlistJsonItems) {
    if (playlistJsonItems.isNotEmpty) {
      return playlistJsonItems
          .map((pl) => PlaylistTile(playlistJsonItems:playlistJsonItems, playlistJsonItem: pl))
          .toList();
    } else {
      [Center(child: Text("No Playlists yet"))];
    }
    return [Container()];
  }
}
