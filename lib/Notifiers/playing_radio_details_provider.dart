import 'package:riverpod/legacy.dart';
import 'package:orbit_radio/model/playing_radio_detail.dart';

class PlayingRadioNotifier extends StateNotifier<PlayingRadioDetail> {
  PlayingRadioNotifier() : super(PlayingRadioDetail(isPlaying: false, stationUuid: ""));

  void updateRadioDetails(PlayingRadioDetail details) {
    // print("Details in update provider - $details");
    state.isPlaying = details.isPlaying;
    state.stationUuid = details.stationUuid;
  }
}

final playingRadioProvider = StateNotifierProvider<PlayingRadioNotifier, PlayingRadioDetail>((ref) {
  return PlayingRadioNotifier();
});
