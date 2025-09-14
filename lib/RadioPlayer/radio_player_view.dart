// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_helper.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class RadioPlayerView extends StatefulWidget {
  const RadioPlayerView(
      {super.key,
      required this.radioStationsList,
      required this.selectedRadioId});
  final List<RadioStation> radioStationsList;
  final String selectedRadioId;
  @override
  State<RadioPlayerView> createState() => _RadioPlayerViewState();
}

class _RadioPlayerViewState extends State<RadioPlayerView> {
  // final GFBottomSheetController _controller = GFBottomSheetController();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  late RadioStation? selectedRadioStation;
  bool _isPlaying = false;
  late bool _isLoading;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedRadioStation = getSelectedRadioStation(
          widget.radioStationsList, widget.selectedRadioId);
      _initAudioPlayer(station: selectedRadioStation);
    });
  }

  Future<void> _initAudioPlayer({RadioStation? station}) async {
    setState(() {
      _isLoading = true;
    });
    _audioPlayer.playerStateStream.listen((playerState) {
      setState(() {
        _isPlaying = playerState.playing;
        if (playerState.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _position = Duration.zero; // Reset position on completion
        }
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    try {
      AudioSource source = AudioSource.uri(
        Uri.parse(station!.url!),
        tag: const MediaItem(
          id: '1',
          title: "Orbit Radio",
        ),
      );
      await _audioPlayer.setAudioSource(source);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _playAudio(RadioStation radioStation) async {
    await _audioPlayer.play();
  }

  Future<void> _stopAudio(RadioStation radioStation) async {
    await _audioPlayer.stop();
  }

  Future<void> _addToFavorites() async {
    await _audioPlayer.stop(); // For assets
  }

  Future<void> _addToPlayList() async {
    await _audioPlayer.stop(); // For assets
  }

  Future<void> _playPrevious() async {
    var index = widget.radioStationsList.indexOf(selectedRadioStation!);
    if (index == 0) {
      return;
    } else {
      var radioStation = widget.radioStationsList[index - 1];
      setState(() {
        selectedRadioStation = radioStation;
      });
      await _initAudioPlayer(station: radioStation);
      _playAudio(radioStation);
    }
  }

  Future<void> _playNext() async {
    var index = widget.radioStationsList.indexOf(selectedRadioStation!);
    if (index == widget.radioStationsList.length - 1) {
      return;
    } else {
      var radioStation = widget.radioStationsList[index + 1];
      setState(() {
        selectedRadioStation = radioStation;
      });
      await _initAudioPlayer(station: radioStation);
      _playAudio(radioStation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
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
                                            avatar: const CircleAvatar(
                                              minRadius: 20,
                                              child: Icon(Icons.tag, size: 20),
                                            ),
                                            label: Text(tag),
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
                          onPressed: () => _addToFavorites(),
                          child: const Icon(Icons.favorite_outline),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(
                                10), // Adjust padding as needed
                          ),
                          onPressed: () => _playPrevious(),
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
                                onPressed: () => !_isPlaying
                                    ? _playAudio(selectedRadioStation!)
                                    : _stopAudio(selectedRadioStation!),
                                child: Icon(!_isPlaying
                                    ? Icons.play_arrow
                                    : Icons.stop_sharp),
                              ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(
                                10), // Adjust padding as needed
                          ),
                          onPressed: () => _playNext(),
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
