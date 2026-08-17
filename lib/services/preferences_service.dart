import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String keyCoins = 'user_coins';
  static const String keyLives = 'user_lives';
  static const String keyHighScore = 'high_score';
  static const String keyUnlockedMedium = 'unlocked_medium';
  static const String keyUnlockedHard = 'unlocked_hard';
  static const String keyLastRewardDate = 'last_reward_date';
  static const String keyStreakCount = 'streak_count';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Coins
  int getCoins() {
    return _prefs.getInt(keyCoins) ?? 0;
  }

  Future<void> addCoins(int amount) async {
    int current = getCoins();
    await _prefs.setInt(keyCoins, current + amount);
  }

  Future<void> setCoins(int coins) async {
    await _prefs.setInt(keyCoins, coins);
  }

  // Lives
  int getLives() {
    return _prefs.getInt(keyLives) ?? 3;
  }

  Future<void> setLives(int lives) async {
    await _prefs.setInt(keyLives, lives);
  }

  // High Score
  int getHighScore() {
    return _prefs.getInt(keyHighScore) ?? 0;
  }

  Future<void> updateHighScore(int score) async {
    int current = getHighScore();
    if (score > current) {
      await _prefs.setInt(keyHighScore, score);
    }
  }

  // Unlocked Levels
  bool isMediumUnlocked() {
    return _prefs.getBool(keyUnlockedMedium) ?? false;
  }

  Future<void> setMediumUnlocked(bool unlocked) async {
    await _prefs.setBool(keyUnlockedMedium, unlocked);
  }

  bool isHardUnlocked() {
    int coins = getCoins();
    bool unlockedByCoins = coins >= 1000;
    bool unlockedByPref = _prefs.getBool(keyUnlockedHard) ?? false;
    return unlockedByCoins || unlockedByPref;
  }

  Future<void> setHardUnlocked(bool unlocked) async {
    await _prefs.setBool(keyUnlockedHard, unlocked);
  }

  // Daily Reward & Streak
  String getLastRewardDate() {
    return _prefs.getString(keyLastRewardDate) ?? '';
  }

  int getStreakCount() {
    return _prefs.getInt(keyStreakCount) ?? 0;
  }

  bool canClaimDailyReward() {
    String today = _formatDate(DateTime.now());
    String lastDate = getLastRewardDate();
    return today != lastDate;
  }

  Future<Map<String, dynamic>> claimDailyReward() async {
    DateTime now = DateTime.now();
    String today = _formatDate(now);
    String lastDate = getLastRewardDate();

    if (today == lastDate) {
      return {'success': false, 'message': 'آپ آج کا انعام پہلے ہی لے چکے ہیں!'};
    }

    int streak = getStreakCount();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    String yesterdayStr = _formatDate(yesterday);

    if (lastDate == yesterdayStr) {
      streak += 1;
    } else {
      streak = 1;
    }

    int rewardCoins = 20;
    bool bonusClaimed = false;

    if (streak == 7) {
      rewardCoins += 100; // 7-day streak bonus
      bonusClaimed = true;
      streak = 0; // reset streak after 7 days
    }

    await addCoins(rewardCoins);
    await _prefs.setString(keyLastRewardDate, today);
    await _prefs.setInt(keyStreakCount, streak);

    return {
      'success': true,
      'coins': rewardCoins,
      'streak': streak,
      'bonus': bonusClaimed,
      'message': bonusClaimed
          ? '🎉 7 دن کی مسلسل حاضری! آپ کو 120 سکے ملے!'
          : '🎁 مبارک ہو! آپ کو $rewardCoins سکے ملے!',
    };
  }

  // Settings: Sound & Vibration
  bool isSoundEnabled() {
    return _prefs.getBool(keySoundEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(keySoundEnabled, enabled);
  }

  bool isVibrationEnabled() {
    return _prefs.getBool(keyVibrationEnabled) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(keyVibrationEnabled, enabled);
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
