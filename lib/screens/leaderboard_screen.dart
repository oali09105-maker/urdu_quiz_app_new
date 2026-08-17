import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/preferences_service.dart';

class LeaderboardScreen extends StatelessWidget {
  final PreferencesService prefsService;

  const LeaderboardScreen({
    super.key,
    required this.prefsService,
  });

  @override
  Widget build(BuildContext context) {
    int userScore = prefsService.getHighScore();
    int coins = prefsService.getCoins();

    int rank = userScore > 500
        ? 1
        : userScore > 200
            ? 3
            : userScore > 50
                ? 8
                : 15;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('لوکل ہائی اسکور (Local High Score)', style: TextStyle(fontFamily: 'UrduNastaliq')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'لوکل ہائی اسکور',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'UrduNastaliq',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
                      const SizedBox(width: 10),
                      Text(
                        '$userScore',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'اسکور: $userScore',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        'سکے: $coins',
                        style: const TextStyle(color: Colors.amber, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Share.share(
                    '🏆 میں نے "اردو الفاظ" گیم میں $userScore اسکور حاصل کیا ہے!',
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text(
                  'اپنا اسکور دوستوں کو بھیجیں',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'UrduNastaliq',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'ٹاپ کھلاڑی (Top Players)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'UrduNastaliq',
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: [
                  _buildLeaderItem(1, 'علی رضا', 1250, Colors.amber),
                  _buildLeaderItem(2, 'عائشہ خان', 1100, Colors.grey.shade400),
                  _buildLeaderItem(3, 'حمزہ احمد', 980, Colors.brown.shade300),
                  _buildLeaderItem(4, 'آپ (You)', userScore, Colors.blueAccent),
                  _buildLeaderItem(5, 'زینب ملک', 450, Colors.white54),
                  _buildLeaderItem(6, 'بلال طارق', 320, Colors.white54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderItem(int position, String name, int score, Color rankColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$score pts',
            style: const TextStyle(
              color: Colors.amberAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'UrduNastaliq',
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 14,
                backgroundColor: rankColor,
                child: Text(
                  '$position',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
