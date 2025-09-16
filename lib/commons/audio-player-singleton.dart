import 'package:just_audio/just_audio.dart';

class AudioPlayerSingleton {
  static final AudioPlayerSingleton _instance = AudioPlayerSingleton._internal();
  late AudioPlayer _audioPlayer;

  // Private constructor
  AudioPlayerSingleton._internal() {
    _audioPlayer = AudioPlayer();
    
  }

  // Static getter to access the single instance
  static AudioPlayerSingleton get instance => _instance;

  // Method to get the underlying Just Audio player
  AudioPlayer get player => _audioPlayer;

  // Example methods to control the player
  Future<void> playAsset(String assetPath) async {
    await _audioPlayer.setAsset(assetPath);
    _audioPlayer.play();
  }

  Future<void> playUrl(String url) async {
    await _audioPlayer.setUrl(url);
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void stop() {
    _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}