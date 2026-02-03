import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  /// Plays audio from the assets/audio/ folder.
  /// [fileName] should be the card ID (e.g. "h3a1b2") 
  /// or ID with suffix (e.g. "h3a1b2_ex")
  static Future<void> play(String fileName) async {
    try {
      // Source points to assets/audio/ by default if organized correctly
      await _player.stop(); // Stop any current audio before playing next
      await _player.play(AssetSource('audio/$fileName.mp3'));
    } catch (e) {
      print("Audio error for $fileName: $e");
    }
  }
}