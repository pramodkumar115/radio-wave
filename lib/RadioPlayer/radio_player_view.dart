import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_visualizer/music_visualizer.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_helper.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/components/add_to_playlist_button.dart';
import 'package:orbit_radio/components/favorites_button.dart';
import 'package:orbit_radio/components/play_stop_button.dart';
import 'package:orbit_radio/model/radio_station.dart';

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
      if (stn != null) {
        selectedRadioStation = RadioStation.fromJson(stn.toJson());
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // _audioPlayer.dispose();
    super.dispose();
  }

  // String _formatDuration(Duration d) {
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
  //   String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
  //   return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  // }

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

      if (next.isPlaying && isCurrentAudio) {
        final current = getSelectedRadioStation(
            widget.radioStationsList, next.currentMediaItem!.id);
        setState(() {
          selectedRadioStation = current;
        });
      }
    });

    final isPlaying = audioPlayerState.isPlaying;
    final isCurrentAudio = audioPlayerState.currentMediaItem?.id ==
        selectedRadioStation!.stationUuid;

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
                    height: screenHeight / 4,
                    child: Container(color: Colors.tealAccent.shade100)),
                Positioned(
                    top: screenHeight * 0.25,
                    right: 0,
                    left: 0,
                    child: Column(children: [
                      Container(
                        height: screenHeight * 0.7,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white),
                      ),
                    ])),
                Positioned(
                    top: screenHeight * 0.1,
                    right: 0,
                    left: 0,
                    child: Column(children: [
                      Container(
                          padding: EdgeInsetsGeometry.only(
                              left: screenWidth * 0.15,
                              right: screenWidth * 0.15),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          width: screenWidth,
                          height: 280,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 218, 218, 219),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                    2.0), // Optional: for rounded corners
                              ),
                              // elevation: 1,
                              surfaceTintColor: Colors.white,
                              color: Colors.white,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey.shade100),
                                  // padding: const EdgeInsets.all(20),
                                  child: _isLoading
                                      ? GFShimmer(child: emptyCardBlock)
                                      : Image.network(
                                          selectedRadioStation!.favicon!,
                                          loadingBuilder: (context, child,
                                                  loadingProgress) =>
                                              (loadingProgress == null)
                                                  ? child
                                                  : const CircularProgressIndicator(),
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            "assets/music.jpg",
                                            // width: 75,
                                            //height: 75
                                          ),
                                        )))),
                      Text(selectedRadioStation!.name ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      )),

                      Text(selectedRadioStation!.country ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                      selectedRadioStation!.tags != null
                          ? Padding(
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
                                                label: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [Text("#$tag")]),
                                                //onDeleted: () => _deleteTag(tag),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 196, 245, 235)));
                                      }).toList())))
                          : Container(),
                      isPlaying ? MusicVisualizer(
                        barCount: 30,
                        colors: [
                          Colors.red[900]!,
                          Colors.green[900]!,
                          Colors.blue[900]!,
                          Colors.brown[900]!
                        ],
                        duration: [900, 700, 600, 800, 500],
                      ) : Container(),
                    ])),
                Positioned(
                    top: screenHeight * 0.7,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsetsDirectional.symmetric(
                          horizontal: screenWidth * 0.05),
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 245, 224, 224),
                              const Color.fromARGB(255, 230, 240, 184)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 20,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50)),
                            child:
                                FavoritesButton(station: selectedRadioStation!),
                          ),
                          isCurrentAudio && isPlaying
                              ? IconButton(
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
                                  icon: const Icon(Icons.skip_previous,
                                      color: Color.fromARGB(255, 0, 29, 10), size: 30))
                              : Container(),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : Transform.scale(
                                  scale: 1.5,
                                  child: PlayStopButton(
                                      stationId:
                                          selectedRadioStation!.stationUuid!,
                                      stationList: widget.radioStationsList)),
                          isCurrentAudio && isPlaying
                              ? IconButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(
                                        10), // Adjust padding as needed
                                  ),
                                  onPressed: () => _playNext(
                                      playerNotifier,
                                      audioPlayerState,
                                      isPlaying,
                                      selectedRadioStation!),
                                  icon: const Icon(Icons.skip_next,
                                      color: Color.fromARGB(255, 0, 29,
                                          10), size: 30) // const Icon(Icons.skip_next),
                                  )
                              : Container(),
                          Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50)),
                              child: AddToPlaylistButton(
                                  station: selectedRadioStation!)),
                        ],
                      ),
                    ))
              ],
            )));
  }

  void _playNext(PlayerNotifier playerNotifier, PlayerState audioPlayerState,
      bool isPlaying, RadioStation currentStation) {
    setSelectedRadioStation(
        audioPlayerState, isPlaying, 'NEXT', currentStation);
    if (isPlaying) {
      playerNotifier.playNext();
    }
  }

  void setSelectedRadioStation(PlayerState audioPlayerState, bool isPlaying,
      String action, RadioStation currentStation) {
    Future.delayed(Duration.zero, () async {
      if (!isPlaying) {
        final current = getSelectedRadioStation(
            widget.radioStationsList, currentStation.stationUuid!);
        final currentIndex = widget.radioStationsList.indexOf(current!);
        debugPrint("${current.name} - $currentIndex");
        setState(() {
          getNextOrPreviousStationDetail(action, current, currentIndex);
        });
      }
    });
  }

  void getNextOrPreviousStationDetail(
      String action, RadioStation current, int currentIndex) {
    if (action.isEmpty) {
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

  void _playPrevious(PlayerNotifier playerNotifier, audioPlayerState, isPlaying,
      currentStation) {
    setSelectedRadioStation(
        audioPlayerState, isPlaying, 'PREVIOUS', currentStation);
    if (isPlaying) {
      playerNotifier.playPrevious();
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
}
