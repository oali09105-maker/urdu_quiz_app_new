import 'package:audioplayers/audioplayers.dart';
import 'preferences_service.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PreferencesService _prefs;

  AudioService(this._prefs);

  Future<void> playCorrectSound() async {
    if (!_prefs.isSoundEnabled()) return;
    try {
      // Using Source for synthesized sound / tone or asset
      await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/cartoon/pop.ogg'));
    } catch (_) {
      // Fallback or mute silently if offline
    }
  }

  Future<void> playWrongSound() async {
    if (!_prefs.isSoundEnabled()) return;
    try {
      await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/cartoon/clack.ogg'));
    } catch (_) {
      // Fallback
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
