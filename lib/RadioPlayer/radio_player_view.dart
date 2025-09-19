import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/Notifiers/playing_radio_details_provider.dart';
import 'package:orbit_radio/Notifiers/recent_visits_notifier.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_helper.dart';
import 'package:orbit_radio/commons/audio-player-singleton.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/playing_radio_detail.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class RadioPlayerView extends ConsumerStatefulWidget {
  const RadioPlayerView(
      {super.key,
      required this.radioStationsList,
      required this.selectedRadioId});
  final List<RadioStation> radioStationsList;
  final String selectedRadioId;

  @override
  ConsumerState<RadioPlayerView> createState() => _RadioPlayerViewState();
}

class _RadioPlayerViewState extends ConsumerState<RadioPlayerView> {
  late RadioStation? selectedRadioStation;
  late bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    var stn = getSelectedRadioStation(
        widget.radioStationsList, widget.selectedRadioId);
    setState(() {
      selectedRadioStation = RadioStation.fromJson(stn!.toJson());
      print(" In Init state ${_isLoading}, ${selectedRadioStation.toString()}");
    });

    Future.delayed(Duration.zero, () async {
      final playerNotifier = ref.read(audioPlayerProvider.notifier);
      final audioPlayerState = ref.watch(audioPlayerProvider);
      print(
          "${audioPlayerState.currentMediaItem?.id}, ${widget.selectedRadioId}");
      if (isSamePlayList(
          audioPlayerState.playListMediaItems, widget.radioStationsList)) {
        // check if not the same station which is already playing
        if (audioPlayerState.currentMediaItem?.id != widget.selectedRadioId) {
          await playerNotifier.seek(widget.radioStationsList.indexOf(stn!));
        }
        setState(() => _isLoading = false);
      }
      else {
        await playerNotifier
            .initPlayer(widget.radioStationsList.map((radioStation) {
          return MediaItem(
            id: radioStation.stationUuid ?? "",
            artUri: Uri.parse(radioStation.url!),
            title: "Orbit Radio - ${radioStation.name}",
            album: radioStation.name,
            displayTitle: radioStation.name,
          );
        }).toList());
        await playerNotifier.seek(widget.radioStationsList.indexOf(stn!));
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    // _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> addToFavorites(
      List<String> favoritesUUIDs, selectedRadioStation) async {
    var message = "";
    if (!favoritesUUIDs.contains(selectedRadioStation!.stationUuid!)) {
      favoritesUUIDs = [...favoritesUUIDs, selectedRadioStation!.stationUuid!];
      message = 'Station added to favorites';
    } else {
      favoritesUUIDs = favoritesUUIDs
          .where((element) => element != selectedRadioStation!.stationUuid!)
          .toList();
      message = 'Station removed from favorites';
    }
    ref.read(favoritesDataProvider.notifier).updateFavorites(favoritesUUIDs);
    GFToast.showToast(message, context);
  }

  Future<void> _addToPlayList() async {
    // await _audioPlayer.stop(); // For assets
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final favoritesUUIDs = ref.watch(favoritesDataProvider);

    return favoritesUUIDs.when(
        data: (favIds) {
          return showContent(screenHeight, screenWidth, context, favIds);
        },
        loading: () => showContent(screenHeight, screenWidth, context, []),
        error: (error, stackTrace) => Center(child: Text('Error: $error')));
  }

  Widget showContent(double screenHeight, double screenWidth,
      BuildContext context, List<String> favIds) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final playerNotifier = ref.read(audioPlayerProvider.notifier);

    ref.listen(audioPlayerProvider, (previous, next) {
      final isCurrentAudio = audioPlayerState.currentMediaItem?.id ==
          selectedRadioStation!.stationUuid;
      print(
          "next - ${next?.currentMediaItem!.album}, ${next?.isPlaying}, ${isCurrentAudio}");

      if (next.isPlaying && isCurrentAudio) {
        final current = getSelectedRadioStation(
            widget.radioStationsList, next.currentMediaItem!.id);
        setState(() {
          selectedRadioStation = current;
        });
      }
    });

    final isCurrentAudio = audioPlayerState.currentMediaItem?.id ==
        selectedRadioStation!.stationUuid;
    final isPlaying = audioPlayerState.isPlaying;

    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        child: SizedBox(
            height: screenHeight * 0.90,
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    height: screenHeight / 5,
                    child: Container(color: Colors.tealAccent.shade100)),
                Positioned(
                    top: screenHeight * 0.15,
                    right: 0,
                    left: 0,
                    child: Column(children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white),
                      ),
                    ])),
                Positioned(
                    top: screenHeight * 0.065,
                    right: screenWidth * 1 / 3,
                    left: screenWidth * 1 / 3,
                    height: screenHeight / 6,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Card(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      color: Color.fromARGB(255, 218, 218,
                                          219), // Specify border color
                                      width: 0.5, // Specify border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        2.0), // Optional: for rounded corners
                                  ),
                                  // elevation: 1,
                                  surfaceTintColor: Colors.white,
                                  color: Colors.white,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey.shade100),
                                      padding: const EdgeInsets.all(20),
                                      child: _isLoading
                                          ? GFShimmer(child: emptyCardBlock)
                                          : Image.network(
                                              selectedRadioStation!.favicon!,
                                              loadingBuilder: (context, child,
                                                      loadingProgress) =>
                                                  (loadingProgress == null)
                                                      ? child
                                                      : const CircularProgressIndicator(),
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                      "assets/music.jpg",
                                                      width: 75,
                                                      height: 75),
                                            )))
                              .w24(context),
                        ])),
                Positioned(
                    top: screenHeight * 0.22,
                    right: 0,
                    left: 0,
                    height: 150,
                    child: _isLoading
                        ? GFShimmer(child: emptyBlock)
                        : Column(children: [
                            Text(selectedRadioStation!.name!)
                                .text
                                .align(TextAlign.center)
                                .xl2
                                .bold
                                .make(),
                            Text(selectedRadioStation!.country!)
                                .text
                                .align(TextAlign.center)
                                .medium
                                .bold
                                .make(),
                            Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                    height: 40,
                                    child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        children: selectedRadioStation!.tags!
                                            .split(",")
                                            .map((tag) {
                                          return Container(
                                              padding: const EdgeInsets.all(2),
                                              child: Chip(
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: Color.fromARGB(
                                                          255,
                                                          162,
                                                          162,
                                                          163), // Specify border color
                                                      width:
                                                          1, // Specify border width
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Optional: for rounded corners
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  label:
                                                      HStack([Text("#$tag")]),
                                                  //onDeleted: () => _deleteTag(tag),
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 196, 245, 235)));
                                        }).toList())))
                          ])),
                Positioned(
                  top: screenHeight * 0.38,
                  right: 0,
                  left: 0,
                  // height: 20,
                  child: _isLoading
                      ? GFShimmer(child: emptyBlock)
                      : Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(
                                      10), // Adjust padding as needed
                                ),
                                onPressed: () => addToFavorites(
                                    favIds, selectedRadioStation),
                                child: favIds.contains(
                                        selectedRadioStation!.stationUuid!)
                                    ? const Icon(Icons.favorite)
                                    : const Icon(Icons.favorite_outline),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(
                                      10), // Adjust padding as needed
                                ),
                                onPressed: () => _playPrevious(
                                    playerNotifier,
                                    audioPlayerState,
                                    isPlaying,
                                    selectedRadioStation),
                                child: const Icon(Icons.skip_previous),
                              ),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(60, 60),
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                      ),
                                      onPressed: () async {
                                        await playOrStop(
                                            isCurrentAudio,
                                            playerNotifier,
                                            isPlaying,
                                            selectedRadioStation!.stationUuid!);
                                      },
                                      child: showIcon(isCurrentAudio, isPlaying,
                                          selectedRadioStation!),
                                    ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(
                                      10), // Adjust padding as needed
                                ),
                                onPressed: () => _playNext(
                                    playerNotifier,
                                    audioPlayerState,
                                    isPlaying,
                                    selectedRadioStation),
                                child: const Icon(Icons.skip_next),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(
                                      10), // Adjust padding as needed
                                ),
                                onPressed: () => _addToPlayList(),
                                child: const Icon(Icons.playlist_add),
                              ),
                            ],
                          ),
                        ),
                )
              ],
            )));
  }

  Future<void> playOrStop(bool isCurrentAudio, PlayerNotifier playerNotifier,
      bool isPlaying, String selectedRadioId) async {
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
  }

  Future<void> playAudioPlayer(
      PlayerNotifier playerNotifier, String selectedRadioId) async {
    var stn = getCurrentRadioStation(selectedRadioId);
    setRecentVisits(stn);
    final index = widget.radioStationsList.indexOf(stn);
    playerNotifier.play(index);
  }

  RadioStation getCurrentRadioStation(String selectedRadioId) {
    RadioStation radioStn = widget.radioStationsList
        .firstWhere((element) => element.stationUuid == selectedRadioId);
    return radioStn;
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

  Transform showIcon(isCurrentAudio, isPlaying, RadioStation station) {
    if (isCurrentAudio) {
      return Transform.scale(
        scale: 2.0, // Doubles the size of the child icon
        child: (isPlaying != true)
            ? const Icon(Icons.play_arrow)
            : const Icon(Icons.stop_sharp),
      );
    } else {
      return Transform.scale(
          scale: 2.0, // Doubles the size of the child icon
          child: const Icon(Icons.play_arrow));
    }
  }

  _playNext(playerNotifier, audioPlayerState, isPlaying, currentStation) {
    setSelectedRadioStation(
        audioPlayerState, isPlaying, 'NEXT', currentStation);
    if (isPlaying) {
      playerNotifier.playNext();
    }
  }

  void setSelectedRadioStation(
      audioPlayerState, isPlaying, action, RadioStation currentStation) {
    Future.delayed(Duration.zero, () async {
      if (!isPlaying) {
        final current = getSelectedRadioStation(
            widget.radioStationsList, currentStation.stationUuid!);
        final currentIndex = widget.radioStationsList.indexOf(current!);
        print("${current.name} - $currentIndex");
        setState(() {
          getNextOrPreviousStationDetail(action, current, currentIndex);
        });
      }
    });
  }

  void getNextOrPreviousStationDetail(
      action, RadioStation current, int currentIndex) {
    if (action == null || action.isEmpty) {
      selectedRadioStation = current;
    } else {
      if (action == 'NEXT' &&
          currentIndex < widget.radioStationsList.length - 1) {
        selectedRadioStation = widget.radioStationsList[currentIndex + 1];
      }
      if (action == 'PREVIOUS' && currentIndex > 0) {
        selectedRadioStation = widget.radioStationsList[currentIndex - 1];
      }
    }
  }

  _playPrevious(playerNotifier, audioPlayerState, isPlaying, currentStation) {
    setSelectedRadioStation(
        audioPlayerState, isPlaying, 'PREVIOUS', currentStation);
    if (isPlaying) {
      playerNotifier.playPrevious();
    }
  }
  
  bool isSamePlayList(List<MediaItem?>? playListMediaItems, List<RadioStation> radioStationsList) {
    var radioIds = radioStationsList.map((r) => r.stationUuid).toList();
    var playListIds = playListMediaItems?.map((r) => r!.id).toList();
    if (playListIds != null) {
      return radioIds.toSet().containsAll(playListIds);
    }
    return false;
    
  }
}
