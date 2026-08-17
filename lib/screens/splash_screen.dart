import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/quiz_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final PreferencesService prefsService;
  final QuizService quizService;

  const SplashScreen({
    super.key,
    required this.prefsService,
    required this.quizService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await widget.prefsService.init();
    await widget.quizService.loadQuestions();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          prefsService: widget.prefsService,
          quizService: widget.quizService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo image - Yellow bulb
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: Image.asset(
                    'assets/images/Gemini_Generated_Image_sdqol1sdqol1sdqo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // App Name Urdu
              const Text(
                'اردو الفاظ',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  fontFamily: 'UrduNastaliq',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // App Name English
              const Text(
                'Urdu Quiz, Trick & Brain Challenge',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Tagline Urdu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Text(
                  'دماغ کی ورزش، الفاظ کا امتحان',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.amberAccent,
                    fontFamily: 'UrduNastaliq',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline English
              const Text(
                'Test Your Mind, Master Urdu Words',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              const CircularProgressIndicator(
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
