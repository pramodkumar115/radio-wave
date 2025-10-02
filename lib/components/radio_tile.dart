import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:music_visualizer/music_visualizer.dart';
import 'package:orbit_radio/Notifiers/addedstreams_state_notifier.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_view.dart';
import 'package:orbit_radio/components/add_to_playlist_button.dart';
import 'package:orbit_radio/components/create_edit_stream.dart';
import 'package:orbit_radio/components/favorites_button.dart';
import 'package:orbit_radio/components/play_stop_button.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:popover/popover.dart';

class RadioTile extends ConsumerStatefulWidget {
  const RadioTile(
      {super.key,
      required this.radio,
      required this.radioStations,
      required this.from});
  final RadioStation radio;
  final List<RadioStation> radioStations;
  final String from;

  @override
  ConsumerState<RadioTile> createState() => _RadioTileState();
}

class _RadioTileState extends ConsumerState<RadioTile> {
  void onMenuClicked(String? value, BuildContext context) {
    Navigator.pop(context);
    if (value == 'DELETE_FROM_PLAYLIST') {
      var playlistName = widget.from.split("|")[1];
      var playListAsync = ref.watch(playlistDataProvider);
      playListAsync.when(
          data: (dataSet) {
            PlayListJsonItem? selectedPlaylist = dataSet
                .firstWhereOrNull((element) => element.name == playlistName);
            if (selectedPlaylist != null) {
              selectedPlaylist.stationIds = selectedPlaylist.stationIds
                  .where((element) => element != widget.radio.stationUuid!)
                  .toList();
            }
            ref.read(playlistDataProvider.notifier).updatePlayList(dataSet);
          },
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          loading: () {});
    }
    if (value == 'DELETE_FROM_ADDED_STREAMS') {
      ref.read(addedStreamsDataProvider.notifier).updateAddedStreams(widget
          .radioStations
          .where((r) => r.stationUuid != widget.radio.stationUuid!)
          .toList());
    }
    if (value == 'EDIT') {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.white,
          builder: (context) => CreateEditStream(
              streams: widget.radioStations, selected: widget.radio));
    }
  }

  List<Widget> getButtons() {
    List<Widget> widgets = [
      FavoritesButton(station: widget.radio),
      PlayStopButton(
          stationId: widget.radio.stationUuid!,
          stationList: widget.radioStations),
      AddToPlaylistButton(station: widget.radio)
    ];

    if (widget.from == 'STREAMS') {
      widgets.add(StreamActions(onMenuClicked: onMenuClicked));
    }
    if (widget.from.contains('PLAYLIST')) {
      widgets.add(PlaylistActions(onMenuClicked: onMenuClicked));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerState = ref.watch(audioPlayerProvider);

    final isCurrentAudio =
        audioPlayerState.currentMediaItem?.id == widget.radio.stationUuid;
    final isPlaying = audioPlayerState.isPlaying;

    return GestureDetector(
        onTap: () {
          if (widget.from != 'RADIO_PLAYER_POPUP') {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              scrollControlDisabledMaxHeightRatio: 1,
              backgroundColor: Colors.grey.shade100,
              builder: (BuildContext context) {
                List<RadioStation> radioStnList = List.empty(growable: true);
                // if (audioPlayerState.playListMediaItems != null && audioPlayerState.playListMediaItems!.isNotEmpty) {
                //   radioStnList = converMediaItemsToRadioList((audioPlayerState.playListMediaItems));
                // } else {
                radioStnList.addAll(widget.radioStations);
                // }
                return RadioPlayerView(
                    radioStationsList: radioStnList,
                    selectedRadioId: widget.radio.stationUuid!);
              },
            );
          }
        },
        child: GFListTile(
            enabled: true,
            selected: true,
            color: Colors.grey.shade50,
            shadow: BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 1, // How blurry the shadow is
                spreadRadius: 1,
                offset: Offset(1, 1)),
            margin: EdgeInsets.all(2),
            avatar: GFAvatar(
                backgroundColor: Colors.white,
                child: Image.network(widget.radio.favicon!,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset("assets/music.jpg"))),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(widget.radio.name!, 
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight:  FontWeight.bold,
              decoration: TextDecoration.underline)),
              isPlaying && isCurrentAudio
                  ? SizedBox(
                    height: 30,
                    child: MusicVisualizer(
                      barCount: 30,
                      colors: [
                        Colors.red[900]!,
                        Colors.green[900]!,
                        Colors.blue[900]!,
                        Colors.brown[900]!
                      ],
                      duration: [900, 700, 600, 800, 500],
                    ))
                  : Container(),
            ]),
            subTitle: Text(widget.radio.country!),
            icon: SizedBox(
                width: 130,
                child: Column(
                  children: [
                    Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [...getButtons()])
                  ],
                ))));
  }
}

class StreamActions extends StatelessWidget {
  const StreamActions({super.key, required this.onMenuClicked});
  final Function onMenuClicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: InkWell(
            child: Icon(Icons.more_vert, // FUI(BoldRounded.MENU_DOTS_VERTICAL,
                size: 30, color: Colors.black)),
        onTap: () {
          showPopover(
              context: context,
              bodyBuilder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView(padding: const EdgeInsets.all(8), children: [
                    InkWell(
                        child: Text("Delete"),
                        onTap: () {
                          onMenuClicked("DELETE_FROM_ADDED_STREAMS", context);
                          Navigator.of(context).pop();
                        }),
                    const Divider(),
                    InkWell(
                        child: Text("Edit"),
                        onTap: () {
                          onMenuClicked("EDIT", context);
                        }),
                  ])),
              onPop: () => debugPrint('Popover was popped!'),
              direction: PopoverDirection.bottom,
              backgroundColor: Colors.white,
              width: 200,
              height: 80,
              arrowHeight: 15,
              arrowWidth: 30);
        });
  }
}

class PlaylistActions extends StatelessWidget {
  const PlaylistActions({super.key, required this.onMenuClicked});
  final Function onMenuClicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: InkWell(
            child: Icon(Icons.more_vert, 
                size: 30, color: Colors.black)),
        onTap: () {
          showPopover(
              context: context,
              bodyBuilder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView(padding: const EdgeInsets.all(8), children: [
                    InkWell(
                        child: Text("Delete"),
                        onTap: () {
                          onMenuClicked("DELETE_FROM_PLAYLIST", context);
                          Navigator.of(context).pop();
                        }),
                  ])),
              onPop: () => debugPrint('Popover was popped!'),
              direction: PopoverDirection.bottom,
              backgroundColor: Colors.white,
              width: 200,
              height: 80,
              arrowHeight: 15,
              arrowWidth: 30);
        });
  }
}
