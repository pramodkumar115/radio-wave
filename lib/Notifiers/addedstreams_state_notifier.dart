import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/model/radio_station.dart';

class AddedStreamsNotifier extends AsyncNotifier<List<RadioStation>> {
  
  @override
  Future<List<RadioStation>> build() async {
    return fetchStreams();
  }

  Future<List<RadioStation>> fetchStreams() async {
    // debugPrint("Came inside fetch Added streams");
    return await getAddedStreamsFromFile();
  }

  // A public method to add a new item, which updates the state.
  Future<void> updateAddedStreams(List<RadioStation> streams) async {
    state = const AsyncLoading();
    await saveAddedStreamsFile(streams);
    state = AsyncData(await fetchStreams());
  }
}

final addedStreamsDataProvider =
    AsyncNotifierProvider<AddedStreamsNotifier, List<RadioStation>>(() {
  return AddedStreamsNotifier();
});
