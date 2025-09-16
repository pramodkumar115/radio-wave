import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';


final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final audioPlayer = AudioPlayer();
  // Dispose of the audio player when the provider is no longer used
  ref.onDispose(() => audioPlayer.dispose());
  return audioPlayer;
});

// Optional: Create a provider for the current player state
final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);
  return audioPlayer.playerStateStream;
});

// Optional: Create a provider for the current player state
final mediaStreamProvider = StreamProvider<SequenceState?>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);
  return audioPlayer.sequenceStateStream;
});

// Optional: Create a provider for the current audio position
final positionStreamProvider = StreamProvider<Duration>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);
  return audioPlayer.positionStream;
});

// Optional: Create a provider for the audio duration
final durationStreamProvider = StreamProvider<Duration?>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);
  return audioPlayer.durationStream;
});