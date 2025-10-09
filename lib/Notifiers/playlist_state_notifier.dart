import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/model/playlist_item.dart';

class PlaylistNotifier extends AsyncNotifier<List<PlayListJsonItem>> {
  
  @override
  Future<List<PlayListJsonItem>> build() async {
    return fetchPlayLists();
  }

  Future<List<PlayListJsonItem>> fetchPlayLists() async {
    // debugPrint("Came inside fetch");
    return await getPlayListsFromFile();
  }

  // A public method to add a new item, which updates the state.
  Future<void> updatePlayList(List<PlayListJsonItem> playListData) async {
    // print("Saving - ${jsonEncode(playListData)}");
    state = const AsyncLoading();
    await savePlaylistFile(playListData);
    state = AsyncData(await fetchPlayLists());
  }
}

final playlistDataProvider =
    AsyncNotifierProvider<PlaylistNotifier, List<PlayListJsonItem>>(() {
  return PlaylistNotifier();
});
