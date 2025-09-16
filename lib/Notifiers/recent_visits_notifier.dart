import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/model/radio_station.dart';

class RecentVisitsNotifier extends AsyncNotifier<List<RadioStation>> {
  @override
  Future<List<RadioStation>> build() async {
    return fetchRecentVisits();
  }

  Future<List<RadioStation>> fetchRecentVisits() async {
    List<String> uuids = await getRecentVisitsFromFile();
    return await getStationsListForUUIDs(uuids);
  }

  // A public method to add a new item, which updates the state.
  Future<void> updateRecentVisits(List<String> recentVisitsUUIDs) async {
    state = const AsyncLoading();
    await saveRecentVisitsFile(recentVisitsUUIDs);
    state = AsyncData(await fetchRecentVisits());
  }
}

final recentVisitsDataProvider =
    AsyncNotifierProvider<RecentVisitsNotifier, List<RadioStation>>(() {
  return RecentVisitsNotifier();
});
