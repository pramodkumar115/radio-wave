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
    await saveFavoritesFile(favoritesUUIDs);
    state = AsyncData(await fetchFavorites());
  }
}

final favoritesDataProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<String>>(() {
  return FavoritesNotifier();
});
