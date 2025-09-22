import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';

class FloatingPlayerView extends ConsumerStatefulWidget {
  const FloatingPlayerView({super.key});

  @override
  ConsumerState<FloatingPlayerView> createState() => _FloatingPlayerViewState();
}

class _FloatingPlayerViewState extends ConsumerState<FloatingPlayerView> {
  @override
  Widget build(BuildContext context) {
      final audioPlayerState = ref.watch(audioPlayerProvider);
    return Positioned(
            //width: screenWidth,
            bottom: 0,
            left: 0,
            right: 0,
            child: GFListTile(
                color: Colors.grey.shade50,
                avatar: const GFAvatar(),
                margin: EdgeInsets.all(0),
                titleText: 'Title',
                subTitleText:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing',
                icon: Icon(Icons.favorite)),
          );
  }
}