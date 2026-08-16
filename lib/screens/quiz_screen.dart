import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/admob_service.dart';
import '../services/audio_service.dart';
import '../services/preferences_service.dart';
import '../services/quiz_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int level;
  final String categoryFilter;
  final List<Question> questions;
  final PreferencesService prefsService;
  final QuizService quizService;

  const QuizScreen({
    super.key,
    required this.level,
    required this.categoryFilter,
    required this.questions,
    required this.prefsService,
    required this.quizService,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late AudioService _audioService;
  int currentIndex = 0;
  int score = 0;
  int coins = 0;
  int lives = 3;

  Timer? _timer;
  int _secondsLeft = 15; // 15 second timer per question (#4)

  String? _selectedOptionLetter; // 'A', 'B', 'C', 'D'
  bool _isAnswered = false;
  bool _showExplanation = false;
  int _questionsAnsweredCount = 0;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService(widget.prefsService);
    coins = widget.prefsService.getCoins();
    lives = 3; // Reset lives for new quiz round
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 15;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        _onTimeOut();
      }
    });
  }

  void _onTimeOut() {
    if (_isAnswered) return;
    _audioService.playWrongSound();

    _questionsAnsweredCount++;

    setState(() {
      _isAnswered = true;
      lives -= 1;
      _showExplanation = true;
    });

    widget.prefsService.setLives(lives);

    _checkAndShowInterstitialAdThenProceed();
  }

  void _onOptionSelected(String optionLetter) {
    if (_isAnswered) return;
    _timer?.cancel();

    Question currentQ = widget.questions[currentIndex];
    bool isCorrect = optionLetter.toUpperCase() == currentQ.correctAnswer;

    _questionsAnsweredCount++;

    setState(() {
      _selectedOptionLetter = optionLetter;
      _isAnswered = true;
      _showExplanation = true;

      if (isCorrect) {
        score += 10;
        coins += 10; // Correct = +10 coins (#3)
        widget.prefsService.addCoins(10);
        _audioService.playCorrectSound();
      } else {
        lives -= 1; // Wrong = -1 life (#3)
        widget.prefsService.setLives(lives);
        _audioService.playWrongSound();
      }
    });

    _checkAndShowInterstitialAdThenProceed();
  }

  void _checkAndShowInterstitialAdThenProceed() {
    // Explanation overlay for 2 seconds (#6)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      // AdMob Requirement 2: Interstitial Ad - Har 3 sawal ke baad
      if (_questionsAnsweredCount > 0 && _questionsAnsweredCount % 3 == 0) {
        AdMobService().showInterstitialAd(
          onAdDismissed: () {
            _proceedToNextQuestionOrResult();
          },
        );
      } else {
        _proceedToNextQuestionOrResult();
      }
    });
  }

  void _proceedToNextQuestionOrResult() {
    if (!mounted) return;

    if (lives <= 0 || currentIndex + 1 >= widget.questions.length) {
      _finishQuiz();
    } else {
      setState(() {
        currentIndex++;
        _selectedOptionLetter = null;
        _isAnswered = false;
        _showExplanation = false;
      });
      _startTimer();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    widget.prefsService.updateHighScore(score);

    // Check level unlocks
    if (widget.level == 1) {
      widget.prefsService.setMediumUnlocked(true);
    } else if (widget.level == 2) {
      widget.prefsService.setHardUnlocked(true);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          earnedCoins: coins,
          totalQuestions: widget.questions.length,
          questionsAnswered: _questionsAnsweredCount,
          prefsService: widget.prefsService,
          quizService: widget.quizService,
          level: widget.level,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Question currentQ = widget.questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text('سوال: ${currentIndex + 1} / ${widget.questions.length}'),
        centerTitle: true,
        actions: [
          Row(
            children: [
              // Lives counter
              Row(
                children: List.generate(3, (index) {
                  return Icon(
                    index < lives ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 10),
              // Coins
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timer progress indicator bar
              LinearProgressIndicator(
                value: _secondsLeft / 15.0,
                backgroundColor: const Color(0xFF1E293B),
                color: _secondsLeft <= 5 ? Colors.redAccent : Colors.amber,
                minHeight: 8,
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'کیٹیگری: ${currentQ.category}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '⏱️ $_secondsLeft سیکنڈ',
                    style: TextStyle(
                      color: _secondsLeft <= 5 ? Colors.redAccent : Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  currentQ.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'UrduNastaliq',
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Options A, B, C, D
              Expanded(
                child: ListView(
                  children: [
                    _buildOptionButton('A', currentQ.optionA, currentQ.correctAnswer),
                    _buildOptionButton('B', currentQ.optionB, currentQ.correctAnswer),
                    _buildOptionButton('C', currentQ.optionC, currentQ.correctAnswer),
                    _buildOptionButton('D', currentQ.optionD, currentQ.correctAnswer),
                  ],
                ),
              ),

              // Explanation Banner (#6)
              if (_showExplanation && currentQ.explanation.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'وضاحت: ${currentQ.explanation}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'UrduNastaliq',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String letter, String text, String correctLetter) {
    if (text.isEmpty) return const SizedBox.shrink();

    Color bgColor = const Color(0xFF1E293B);
    Color borderColor = const Color(0xFF334155);

    if (_isAnswered) {
      if (letter.toUpperCase() == correctLetter.toUpperCase()) {
        bgColor = Colors.green.shade800;
        borderColor = Colors.greenAccent;
      } else if (_selectedOptionLetter == letter) {
        bgColor = Colors.red.shade800;
        borderColor = Colors.redAccent;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () => _onOptionSelected(letter),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black38,
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'UrduNastaliq',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
