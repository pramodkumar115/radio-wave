// player_notifier.dart
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:orbit_radio/Notifiers/recent_visits_notifier.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orbit_radio/model/radio_media_item.dart';

// The state of our player
class PlayerState {
  final bool isPlaying;
  final MediaItem? currentMediaItem;
  final List<MediaItem?>? playListMediaItems;

  PlayerState(
      {this.isPlaying = false, this.currentMediaItem, this.playListMediaItems});

  PlayerState copyWith({
    bool? isPlaying,
    MediaItem? currentMediaItem,
    List<MediaItem?>? playListMediaItems,
  }) {
    return PlayerState(
        isPlaying: isPlaying ?? this.isPlaying,
        currentMediaItem: currentMediaItem ?? this.currentMediaItem,
        playListMediaItems: playListMediaItems ?? this.playListMediaItems);
  }
}

// The StateNotifier that manages the audio player
class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier() : super(PlayerState()) {
    _player = AudioPlayer();
    _initListeners();
  }

  late final AudioPlayer _player;

  // Initialize the player and set up listeners
  Future<void> initPlayer(
      List<PlayingRadioUriMediaItem> mediaItemList, int? index) async {
    List<AudioSource> playlist = mediaItemList
        .map((radioMediaItem) => AudioSource.uri(
            Uri.parse(radioMediaItem.uriString!),
            tag: radioMediaItem.mediaItem))
        .toList();
    await _player.setAudioSources(playlist, initialIndex: index ?? 0);
  }

  Future<void> setRecentVisits(MediaItem? mediaItem) async {
    final recentVisitsNotifier = RecentVisitsNotifier();

    bool isPlaying = _player.playerState.playing;
    if (isPlaying && mediaItem != null) {
      // print("Came Here in set recent visits");
      List<String> recentVisitedIds = await getRecentVisitsFromFile();
      if (recentVisitedIds.contains(mediaItem.id)) {
        recentVisitedIds.removeAt(recentVisitedIds.indexOf(mediaItem.id));
      }
      recentVisitedIds.insert(0, mediaItem.id);
      if (recentVisitedIds.length >= 15) {
        recentVisitedIds.removeRange(15, recentVisitedIds.length);
      }
      // print("recentVisitedIds - $recentVisitedIds");

      await saveRecentVisitsFile(recentVisitedIds);
      recentVisitsNotifier.build();
    }
  }

  // Set up listeners for the player's stream
  void _initListeners() {
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      state = state.copyWith(isPlaying: isPlaying);
      if (isPlaying) {
        // print("Came inside is playing true - ${_player.sequenceState.currentSource?.tag?.id}");
        if (_player.sequenceState.currentSource != null) {
          setRecentVisits(_player.sequenceState.currentSource?.tag);
        }
      }
    });

    // Listen for changes to the currently playing item
    _player.sequenceStateStream.listen((sequenceState) {
      final mediaItem = sequenceState.currentSource?.tag as MediaItem?;
      final List<MediaItem?> seqList = List.empty(growable: true);
      if (sequenceState.effectiveSequence.isNotEmpty) {
        seqList.addAll(
            sequenceState.effectiveSequence.map((s) => s.tag as MediaItem?));
      }
      state = state.copyWith(
          currentMediaItem: mediaItem, playListMediaItems: seqList);
    });

    _player.errorStream.listen((data) async {
      print("Error data while playing - $data");
      print("------------ First one");
      await _player.seekToNext();
      await _player.play();
      print("------------ Next one");
    });
  }

  // Control methods
  void play(int index) async {
    // debugPrint("index - $index");
    await seek(index);
    try {
      await _player.play();
    } catch (e) {
      print("ERROR ------ $e");
    }
  }

  Future<void> seek(int index) async {
    await _player.seek(Duration.zero, index: index);
  }

  void playNext() async {
    await _player.seekToNext();
  }

  void playPrevious() async {
    await _player.seekToPrevious();
  }

  void pause() async {
    await _player.pause();
  }

  void stop() async {
    await _player.stop();
    state = state.copyWith(isPlaying: false, currentMediaItem: null);
  }

  // Make sure to dispose the player
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

// The provider to be used by the UI
final audioPlayerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});
