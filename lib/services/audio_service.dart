import 'package:audioplayers/audioplayers.dart';
import 'preferences_service.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PreferencesService _prefs;

  AudioService(this._prefs);

  Future<void> playCorrectSound() async {
    if (!_prefs.isSoundEnabled()) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/tick.mp3'));
    } catch (_) {
      // Fallback or mute silently if error
    }
  }

  Future<void> playWrongSound() async {
    if (!_prefs.isSoundEnabled()) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
    } catch (_) {
      // Fallback
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
