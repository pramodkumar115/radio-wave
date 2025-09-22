import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/components/add_to_playlist_button.dart';
import 'package:orbit_radio/components/favorites_button.dart';
import 'package:orbit_radio/components/play_stop_button.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class RadioTile extends ConsumerStatefulWidget {
  const RadioTile({super.key, required this.radio, required this.radioStations});
  final RadioStation? radio;
  final List<RadioStation> radioStations;

  @override
  ConsumerState<RadioTile> createState() => _RadioTileState();
}

class _RadioTileState extends ConsumerState<RadioTile> {
  @override
  Widget build(BuildContext context) {
    final audioPlayerState = ref.watch(audioPlayerProvider);

    final isCurrentAudio = audioPlayerState.currentMediaItem?.id == widget.radio!.stationUuid;
    final isPlaying = audioPlayerState.isPlaying;

    return GFListTile(
      enabled: true,
      selected: true,
      color: Colors.grey.shade50,
      avatar: GFAvatar(
          backgroundColor: Colors.white,
          child: Image.network(widget.radio!.favicon!,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset("assets/music.jpg"))),
      title: VStack([
        Text(widget.radio!.name!, textAlign: TextAlign.start).text.bold.align(TextAlign.start).make(),
        (isPlaying && isCurrentAudio ? Image.asset("assets/equalizer.gif", height: 50) : Container())
        ]),
      subTitle: Text(widget.radio!.country!),

      icon: SizedBox(
          width: 120,
          child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
            FavoritesButton(station: widget.radio!),
            PlayStopButton(
                stationId: widget.radio!.stationUuid!, stationList: widget.radioStations),
            AddToPlaylistButton(station: widget.radio!)
          ])),
    );
  }
}
