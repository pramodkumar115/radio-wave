import 'package:getwidget/getwidget.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
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

  RadioStation convertMediaItemToRadio(MediaItem currentMediaItem) {
    return RadioStation(
        stationUuid: currentMediaItem.id,
        country: currentMediaItem.artist,
        name: currentMediaItem.album,
        favicon: currentMediaItem.artUri?.toString(),
        tags: currentMediaItem.genre);
  }

  List<RadioStation> converMediaItemsToRadioList(
      List<MediaItem?>? playListMediaItems) {
    List<RadioStation> stations = List.empty(growable: true);
    if (playListMediaItems != null) {
      for (var i = 0; i < playListMediaItems.length; i++) {
        if (playListMediaItems[i] != null) {
          stations.add(convertMediaItemToRadio(playListMediaItems[i]!));
        }
      }
    }
    return stations;
  }
}
