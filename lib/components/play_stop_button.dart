import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/Notifiers/recent_visits_notifier.dart';
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
  late bool _isLoading = true;

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
    if (playListIds != null) {
      return radioIds.toSet().containsAll(playListIds);
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

  Transform showIcon(isCurrentAudio, isPlaying, RadioStation station) {
    if (isCurrentAudio) {
      return Transform.scale(
          scale: 1.2, // Doubles the size of the child icon
          child: (isPlaying != true)
              ? const FUI(RegularRounded.PLAY)
              : const FUI(RegularRounded.STOP));
    } else {
      return Transform.scale(
          scale: 1.2, // Doubles the size of the child icon
          child:
              const FUI(RegularRounded.PLAY)); // const Icon(Icons.play_arrow));
    }
  }

  void setRecentVisits(RadioStation radioStation) {
    var recentVisitList = ref.watch(recentVisitsDataProvider);
    var recentVisitsNotifier = ref.read(recentVisitsDataProvider.notifier);
    recentVisitList.when(
        data: (recentVisitedStations) {
          print("recent - $recentVisitedStations");
          if (recentVisitedStations
              .where((st) => st.stationUuid == radioStation.stationUuid)
              .isNotEmpty) {
            print("recent Inside - ${recentVisitedStations.length}");
            recentVisitedStations = recentVisitedStations
                .where((st) => st.stationUuid != radioStation.stationUuid)
                .toList();
          }
          print("recent Outside - ${recentVisitedStations.length}");
          if (recentVisitedStations.length > 10) {
            recentVisitedStations.removeLast();
          }
          recentVisitedStations.insert(0, radioStation);
          if (recentVisitedStations.isNotEmpty) {
            List<String> uuids = recentVisitedStations
                .map((element) => element.stationUuid ?? "")
                .toList();
            recentVisitsNotifier.updateRecentVisits([...uuids]);
          }
        },
        error: (error, stackTrace) => () => {},
        loading: () => {});
  }

  Future<void> playAudioPlayer(
      PlayerNotifier playerNotifier, String selectedRadioId) async {
    var stn = getSelectedRadioStation(widget.stationList, selectedRadioId);
    if (stn != null) {
      setRecentVisits(stn);
      final index = widget.stationList.indexOf(stn);
      playerNotifier.play(index);
    }
  }

  Future<void> playOrStop(bool isCurrentAudio, PlayerNotifier playerNotifier,
      bool isPlaying, String selectedRadioId) async {
    final playerNotifier = ref.read(audioPlayerProvider.notifier);
    final audioPlayerState = ref.watch(audioPlayerProvider);
    var stn = getSelectedRadioStation(widget.stationList, widget.stationId);
    print("${audioPlayerState.currentMediaItem?.id}, ${widget.stationId}");
    if (isSamePlayList(
        audioPlayerState.playListMediaItems, widget.stationList)) {
      // check if not the same station which is already playing
      if (audioPlayerState.currentMediaItem?.id != widget.stationId) {
        await playerNotifier.seek(widget.stationList.indexOf(stn!));
      }
      setState(() => _isLoading = false);
    } else {
      await playerNotifier.initPlayer(widget.stationList.map((radioStation) {
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
      }).toList());
      await playerNotifier.seek(widget.stationList.indexOf(stn!));
      setState(() => _isLoading = false);
    }
    Future.delayed(Duration.zero, () async {
      print("$isCurrentAudio, $isPlaying, $selectedRadioId");
      if (!isCurrentAudio) {
        await playAudioPlayer(playerNotifier, selectedRadioId);
      } else {
        if (isPlaying) {
          playerNotifier.stop();
        } else {
          await playAudioPlayer(playerNotifier, selectedRadioId);
        }
      }
      print("$isCurrentAudio, $isPlaying, $selectedRadioId");
    });
  }

  showContent(favIds, stationId) {
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

    return GestureDetector(
      child: showIcon(isCurrentAudio, isPlaying, station!),
      onTap: () async {
        await playOrStop(
            isCurrentAudio, playerNotifier, isPlaying, station!.stationUuid!);
      },
    );
  }
}
