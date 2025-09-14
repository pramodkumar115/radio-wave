import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_helper.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
  final GFBottomSheetController _controller = GFBottomSheetController();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  late RadioStation? selectedRadioStation;
  PlayerState stateOfPlayer = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _controller.showBottomSheet();
    setState(() {
      selectedRadioStation = getSelectedRadioStation(
          widget.radioStationsList, widget.selectedRadioId);
    });
  }

  Future<void> _playAudio(RadioStation radioStation) async {
    try {
      await _audioPlayer.play(UrlSource(radioStation.url!)); // For assets
      print(_audioPlayer.state.name);
      setState(() {
        stateOfPlayer = _audioPlayer.state;
      });
    } catch (id) {
      print("Error ID - $id");
      await _audioPlayer.play(UrlSource(radioStation.urlResolved!));
    }
  }

  Future<void> _stopAudio(RadioStation radioStation) async {
    await _audioPlayer.stop(); // For assets
    print(_audioPlayer.state.name);
    setState(() {
        stateOfPlayer = _audioPlayer.state;
      });
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
                    height: 250,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                    )),
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
                        PlayerState.playing != stateOfPlayer
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(
                                      10), // Adjust padding as needed
                                ),
                                onPressed: () =>
                                    _playAudio(selectedRadioStation!),
                                child: const Icon(Icons.play_arrow),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(
                                      10), // Adjust padding as needed
                                ),
                                onPressed: () =>
                                    _stopAudio(selectedRadioStation!),
                                child: const Icon(Icons.stop_sharp),
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
