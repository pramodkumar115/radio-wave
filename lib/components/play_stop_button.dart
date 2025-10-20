import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_helper.dart';
import 'package:orbit_radio/model/radio_media_item.dart';
import 'package:orbit_radio/model/radio_station.dart';

class PlayStopButton extends ConsumerStatefulWidget {
  const PlayStopButton(
      {super.key, required this.stationId, required this.stationList});
  final String stationId;
  final List<RadioStation> stationList;

  @override
  ConsumerState<PlayStopButton> createState() => _PlayStopButtonState();
}

class _PlayStopButtonState extends ConsumerState<PlayStopButton> {
  RadioStation? station;
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    var stn = getSelectedRadioStation(widget.stationList, widget.stationId);
    if (stn != null) {
      setState(() {
        station = RadioStation.fromJson(stn.toJson());
      });
    }
  }

  bool isSamePlayList(List<MediaItem?>? playListMediaItems,
      List<RadioStation> radioStationsList) {
    var radioIds = radioStationsList.map((r) => r.stationUuid).toList();
    var playListIds = playListMediaItems?.map((r) => r!.id).toList();
    if (radioIds.length == playListIds?.length) {
      if (playListIds != null && playListIds.isNotEmpty) {
        for (var i = 0; i < radioIds.length; i++) {
          if (radioIds[i] != playListIds[i]) {
            return false;
          }
        }
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final favoritesUUIDs = ref.watch(favoritesDataProvider);

    return favoritesUUIDs.when(
        data: (favIds) {
          return showContent(favIds, widget.stationId);
        },
        loading: () => showContent([], widget.stationId),
        error: (error, stackTrace) => Center(child: Text('Error: $error')));
  }

  Widget showIcon(bool isCurrentAudio, bool isPlaying, RadioStation station) {
    if (_isLoading) return CircularProgressIndicator();
    if (isCurrentAudio) {
      return (isPlaying != true)
          ? const Icon(Icons.play_arrow,
              color: Color.fromARGB(255, 0, 29, 10), size: 40)
          : const Icon(Icons.stop_sharp,
              color: Color.fromARGB(255, 0, 29, 10), size: 40);
    } else {
      return const Icon(
        Icons.play_arrow,
        color: Color.fromARGB(255, 0, 29, 10),
        size: 40,
      ); // const Icon(Icons.play_arrow));
    }
  }

  Future<void> playAudioPlayer(
      PlayerNotifier playerNotifier, RadioStation? stn) async {
    await Future.delayed(Duration.zero);
    if (stn != null) {
      final index = widget.stationList.indexOf(stn);
      try {
        playerNotifier.play(index);
      } catch (e) {
        print("ERROR ----- $e");
      }
    }
  }

  Future<void> playOrStop(bool isCurrentAudio, PlayerNotifier playerNotifier,
      bool isPlaying, String selectedRadioId) async {
    final playerNotifier = ref.read(audioPlayerProvider.notifier);
    final audioPlayerState = ref.watch(audioPlayerProvider);
    var stn = getSelectedRadioStation(widget.stationList, widget.stationId);
    setState(() => _isLoading = true);
    if (isSamePlayList(
        audioPlayerState.playListMediaItems, widget.stationList)) {
      if (audioPlayerState.currentMediaItem?.id != widget.stationId) {
        await playerNotifier.seek(widget.stationList.indexOf(stn!));
      }
      setState(() => _isLoading = false);
    } else {
      await playerNotifier.initPlayer(
          widget.stationList.map((radioStation) {
            return PlayingRadioUriMediaItem(
                uriString: radioStation.url!,
                mediaItem: MediaItem(
                    id: radioStation.stationUuid ?? "",
                    artUri: radioStation.favicon != null
                        ? Uri.parse(radioStation.favicon!)
                        : Uri.parse("/assets/music.jpg"),
                    title: "Orbit Radio: ${radioStation.name}",
                    album: radioStation.name,
                    displayTitle: radioStation.name,
                    artist: radioStation.country,
                    genre: radioStation.tags));
          }).toList(),
          widget.stationList.indexOf(stn!));
      await playerNotifier.seek(widget.stationList.indexOf(stn));
      setState(() => _isLoading = false);
    }
    Future.delayed(Duration.zero, () async {
      if (!isCurrentAudio) {
        await playAudioPlayer(playerNotifier, stn);
      } else {
        if (isPlaying) {
          playerNotifier.stop();
        } else {
          await playAudioPlayer(playerNotifier, stn);
        }
      }
      Timer(
        Duration(seconds: 5),
        () => setState(() {
              _isLoading = false;
            }));
    });
    
  }

  Widget showContent(List<String> favIds, String stationId) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final playerNotifier = ref.read(audioPlayerProvider.notifier);
    final isCurrentAudio = audioPlayerState.currentMediaItem?.id == stationId;
    final isPlaying = audioPlayerState.isPlaying;

    ref.listen(audioPlayerProvider, (previous, next) {
      final isCurrentAudio = audioPlayerState.currentMediaItem?.id == stationId;

      if (next.isPlaying && isCurrentAudio) {
        final RadioStation? current = getSelectedRadioStation(
            widget.stationList, next.currentMediaItem!.id);
        if (current != null) {
          setState(() {
            station = RadioStation.fromJson(current.toJson());
          });
        }
      }
    });

    return InkWell(
      child: showIcon(isCurrentAudio, isPlaying, station!),
      onTap: () async {
        await playOrStop(
            isCurrentAudio, playerNotifier, isPlaying, station!.stationUuid!);
      },
    );
  }
}
