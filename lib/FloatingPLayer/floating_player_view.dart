import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';

class FloatingPlayerView extends ConsumerStatefulWidget {
  const FloatingPlayerView({super.key});

  @override
  ConsumerState<FloatingPlayerView> createState() => _FloatingPlayerViewState();
}

class _FloatingPlayerViewState extends ConsumerState<FloatingPlayerView> {
  @override
  Widget build(BuildContext context) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    RadioStation? radio;
    if (audioPlayerState.currentMediaItem != null) {
      radio = convertMediaItemToRadio(audioPlayerState.currentMediaItem!);
    }
    List<RadioStation>? radioStations =
        converMediaItemsToRadioList(audioPlayerState.playListMediaItems);

    if (radio != null) {
      return RadioTile(
          radio: radio, radioStations: radioStations, from: "FLOATING_PLAYER");
    } else {
      return Container();
    }
  }

 

  
}
