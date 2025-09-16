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
  late final AudioPlayer _audioPlayer;
  late RadioStation? selectedRadioStation;
  bool _isPlaying = false;
  // List<String> favoritesUUIDs = List.empty(growable: true);
  late bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    setState(() {
      print("-----------In radio player------------");
      selectedRadioStation = getSelectedRadioStation(
          widget.radioStationsList, widget.selectedRadioId);
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

  Future<void> _playAudio(RadioStation radioStation, audioPlayer) async {
    MediaItem media = MediaItem(
      id: radioStation.serverUuid ?? "",
      title: "Orbit Radio",
      album: radioStation.name,
      displayTitle: radioStation.name,
    );
    AudioSource source =
        AudioSource.uri(Uri.parse(radioStation.url!), tag: media);
    var recentVisitList = ref.watch(recentVisitsDataProvider);
    recentVisitList.when(
        data: (recentVisitedStations) {
          if (recentVisitedStations
              .where((st) => st.stationUuid == radioStation.stationUuid)
              .isNotEmpty) {
            recentVisitedStations = recentVisitedStations
                .where((st) => st.stationUuid != radioStation.stationUuid)
                .toList();
          }
          if (recentVisitedStations.length > 10) {
            recentVisitedStations.removeLast();
          }
          recentVisitedStations.insert(0, radioStation);
          if (recentVisitedStations.isNotEmpty) {
            List<String> uuids = recentVisitedStations
                .map((element) => element.stationUuid ?? "")
                .toList();
            ref
                .read(recentVisitsDataProvider.notifier)
                .updateRecentVisits(uuids);
          }
        },
        error: (error, stackTrace) => () => {},
        loading: () => {});
    await audioPlayer.setAudioSource(source);
    await audioPlayer.play();
  }

  Future<void> _stopAudio(RadioStation radioStation, audioPlayer) async {
    // var playingRadio = ref.watch(playingRadioProvider);
    // print("ref.watch(playingRadioProvider) ${{
    //   'stationId': playingRadio.stationUuid,
    //   'isPlaying': playingRadio.isPlaying
    // }}");
    // if (playingRadio.stationUuid == radioStation.stationUuid) {
    //   ref.read(playingRadioProvider.notifier).updateRadioDetails(
    //       PlayingRadioDetail(
    //           isPlaying: false,
    //           stationUuid: selectedRadioStation!.stationUuid ?? ""));
    await audioPlayer.stop();
    // }
  }

  Future<void> addToFavorites(List<String> favoritesUUIDs) async {
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

  Future<void> _playPrevious(audioPlayer) async {
    var index = widget.radioStationsList.indexOf(selectedRadioStation!);
    if (index == 0) {
      return;
    } else {
      var radioStation = widget.radioStationsList[index - 1];
      setState(() {
        selectedRadioStation = radioStation;
      });
      // await _initAudioPlayer(station: radioStation);
      _playAudio(radioStation, audioPlayer);
    }
  }

  Future<void> _playNext(audioPlayer) async {
    var index = widget.radioStationsList.indexOf(selectedRadioStation!);
    if (index == widget.radioStationsList.length - 1) {
      return;
    } else {
      var radioStation = widget.radioStationsList[index + 1];
      setState(() {
        selectedRadioStation = radioStation;
      });
      // await _initAudioPlayer(station: radioStation);
      _playAudio(radioStation, audioPlayer);
    }
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

  ClipRRect showContent(double screenHeight, double screenWidth,
      BuildContext context, List<String> favIds) {
    final audioPlayer = ref.watch(audioPlayerProvider);
    final playerState = ref.watch(playerStateStreamProvider);
    final mediaState = ref.watch(mediaStreamProvider);
    final position = ref.watch(positionStreamProvider);
    final duration = ref.watch(durationStreamProvider);

    final mediaItem = mediaState.value?.currentSource?.tag;

    print(
        "mediaState - ${mediaState.value?.currentSource?.tag?.toString()}, $playerState");
    // print(
    //     "current play - ${playingRadioDetail.stationUuid}, ${selectedRadioStation!.stationUuid!}, ${{'playerState': playerState.value}}");

    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        child: SizedBox(
            height: screenHeight * 0.90, // Adjust height as needed
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
                        height: 250,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white),
                      ),
                      // const Text("Testing")
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
                              // elevation: 4,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey.shade100),
                                  padding: const EdgeInsets.all(20),
                                  child: Image.network(
                                    selectedRadioStation!.favicon!,
                                    loadingBuilder: (context, child,
                                            loadingProgress) =>
                                        (loadingProgress == null)
                                            ? child
                                            : const CircularProgressIndicator(),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset("assets/music.jpg",
                                                width: 75, height: 75),
                                  ))).w24(context),
                        ])),
                Positioned(
                    top: screenHeight * 0.22,
                    right: 0,
                    left: 0,
                    height: 150,
                    child: Column(children: [
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
                                            padding: const EdgeInsets.all(0),
                                            label: HStack([Text("#$tag")]),
                                            //onDeleted: () => _deleteTag(tag),
                                            backgroundColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1)
                                            // deleteIcon: const Icon(Icons.cancel),
                                            ));
                                  }).toList())))
                    ])),
                Positioned(
                  top: screenHeight * 0.36,
                  right: 0,
                  left: 0,
                  // height: 20,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(
                                10), // Adjust padding as needed
                          ),
                          onPressed: () => addToFavorites(favIds),
                          child: favIds
                                  .contains(selectedRadioStation!.stationUuid!)
                              ? const Icon(Icons.favorite)
                              : const Icon(Icons.favorite_outline),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(
                                10), // Adjust padding as needed
                          ),
                          onPressed: () => _playPrevious(audioPlayer),
                          child: const Icon(Icons.arrow_back),
                        ),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(
                                      10), // Adjust padding as needed
                                ),
                                onPressed: () => {
                                  playerState.value?.playing != true
                                      ? _playAudio(
                                          selectedRadioStation!, audioPlayer)
                                      : _stopAudio(
                                          selectedRadioStation!, audioPlayer)
                                },
                                child: (playerState.value?.playing != true)
                                    ? const Icon(Icons.play_arrow)
                                    : const Icon(Icons.stop_sharp),
                              ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(
                                10), // Adjust padding as needed
                          ),
                          onPressed: () => _playNext(audioPlayer),
                          child: const Icon(Icons.arrow_forward),
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
}
