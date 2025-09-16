// player_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

// The state of our player
class PlayerState {
  final bool isPlaying;
  final MediaItem? currentMediaItem;

  PlayerState({
    this.isPlaying = false,
    this.currentMediaItem,
  });

  PlayerState copyWith({
    bool? isPlaying,
    MediaItem? currentMediaItem,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentMediaItem: currentMediaItem ?? this.currentMediaItem,
    );
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
  Future<void> initPlayer(String url, MediaItem mediaItem) async {
    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(url),
        tag: mediaItem,
      ),
    );
  }

  // Set up listeners for the player's stream
  void _initListeners() {
    // Listen for changes in the playback state
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      state = state.copyWith(isPlaying: isPlaying);
    });

    // Listen for changes to the currently playing item
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        final mediaItem = sequenceState.currentSource?.tag as MediaItem?;
        state = state.copyWith(currentMediaItem: mediaItem);
      }
    });
  }

  // Control methods
  void play() async {
    await _player.play();
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
final audioPlayerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});