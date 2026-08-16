import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../services/admob_service.dart';
import '../services/preferences_service.dart';
import '../services/quiz_service.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int earnedCoins;
  final int totalQuestions;
  final int questionsAnswered;
  final PreferencesService prefsService;
  final QuizService quizService;
  final int level;

  const ResultScreen({
    super.key,
    required this.score,
    required this.earnedCoins,
    required this.totalQuestions,
    required this.questionsAnswered,
    required this.prefsService,
    required this.quizService,
    required this.level,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService().createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = false;
          });
        }
      },
    );
    _bannerAd?.load();
  }

  void _shareScore() {
    String shareMessage =
        '🎯 میں نے "اردو کوئز گیم" میں ${widget.score} اسکور حاصل کیا!\n'
        'کیا آپ مجھ سے زیادہ اسکور کر سکتے ہیں؟ ابھی کھیلے:\n'
        'App Name: اردو الفاظ (Urdu Quiz, Trick & Brain Challenge)';
    Share.share(shareMessage);
  }

  void _fillLivesWithRewardedAd() {
    AdMobService().showRewardedAd(
      onUserEarnedReward: () {
        widget.prefsService.setLives(3);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 آپ کی زندگی دوبارہ 3 ہو گئی ہے!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onAdFailed: () {
        widget.prefsService.setLives(3);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('زندگی دوبارہ بھر دی گئی ہے!'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  void _restartGame() {
    var questions = widget.quizService.getQuestionsByLevel(widget.level);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          level: widget.level,
          categoryFilter: 'All',
          questions: questions,
          prefsService: widget.prefsService,
          quizService: widget.quizService,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalCoins = widget.prefsService.getCoins();

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('نتیجہ (Result)', style: TextStyle(fontFamily: 'UrduNastaliq')),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.amber, size: 70),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    '🎉 کھیل مکمل!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'UrduNastaliq',
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('کل اسکور:', '${widget.score}'),
                        const Divider(color: Colors.white24, height: 24),
                        _buildStatRow('حاصل کردہ سکے:', '+${widget.earnedCoins}'),
                        const Divider(color: Colors.white24, height: 24),
                        _buildStatRow('کل سکے:', '$totalCoins'),
                        const Divider(color: Colors.white24, height: 24),
                        _buildStatRow('کل حل شدہ سوالات:', '${widget.questionsAnswered}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _restartGame,
                      icon: const Icon(Icons.replay),
                      label: const Text(
                        'دوبارہ کھیلیں',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'UrduNastaliq',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _fillLivesWithRewardedAd,
                      icon: const Icon(Icons.favorite),
                      label: const Text(
                        'جان بھرو (ویڈیو دیکھیں)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'UrduNastaliq',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: const BorderSide(color: Colors.amber, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _shareScore,
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
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'مین مینو میں واپس جائیں',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'UrduNastaliq',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'UrduNastaliq',
          ),
        ),
      ],
    );
  }
}
