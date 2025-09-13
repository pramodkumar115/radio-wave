import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_helper.dart';
import 'package:orbit_radio/model/radio_station.dart';

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
  late AudioPlayer _audioPlayer;
  late RadioStation? selectedRadioStation;

  @override
  void initState() {
    super.initState();
    _controller.showBottomSheet();
    _audioPlayer = AudioPlayer();
    selectedRadioStation = getSelectedRadioStation(
        widget.radioStationsList, widget.selectedRadioId);
  }

  Future<void> _playAudio() async {
    await _audioPlayer
        .play(UrlSource(selectedRadioStation!.url!)); // For assets
    // Or for a URL: await _audioPlayer.play(UrlSource('https://example.com/audio.mp3'));
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop(); // For assets
    // Or for a URL: await _audioPlayer.play(UrlSource('https://example.com/audio.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height * 0.90, // Adjust height as needed
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _playAudio(),
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: () => _stopAudio(),
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
