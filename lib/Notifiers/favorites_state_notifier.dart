// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:orbit_radio/commons/util.dart';

// class FavoritesDataNotifier extends StateNotifier<List<String>> {
//   FavoritesDataNotifier() : super([]);

//   void updateFavoritesList(List<String> favoritesList) {
//     state = favoritesList;
//   }

//   void initFavoritesList() async {
//     print("In Init favorites");
//     state = await getFavoritesFromFile();
//   }
// }

// final favoritesDataProvider = StateNotifierProvider<FavoritesDataNotifier, List<String>> ((ref) {
//   return FavoritesDataNotifier();
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/commons/file-helper-util.dart';
import 'dart:convert';
import 'package:orbit_radio/commons/util.dart';

class FavoritesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return fetchFavorites();
  }

  Future<List<String>> fetchFavorites() async {
    return await getFavoritesFromFile();
  }

  // A public method to add a new item, which updates the state.
  Future<void> updateFavorites(List<String> favoritesUUIDs) async {
    state = const AsyncLoading();
    await writeData("favorites.json", json.encode(favoritesUUIDs));
    state = AsyncData(await fetchFavorites());
  }
}

final favoritesDataProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<String>>(() {
  return FavoritesNotifier();
});
