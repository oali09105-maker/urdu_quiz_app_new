import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/admob_service.dart';
import 'services/preferences_service.dart';
import 'services/quiz_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdMobService().initialize();

  final prefsService = PreferencesService();
  final quizService = QuizService();

  runApp(UrduQuizApp(
    prefsService: prefsService,
    quizService: quizService,
  ));
}

class UrduQuizApp extends StatelessWidget {
  final PreferencesService prefsService;
  final QuizService quizService;

  const UrduQuizApp({
    super.key,
    required this.prefsService,
    required this.quizService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urdu Quiz, Trick & Brain Challenge',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ur', 'PK'),
      supportedLocales: const [
        Locale('ur', 'PK'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        fontFamily: 'UrduNastaliq',
        primarySwatch: Colors.amber,
      ),
      home: SplashScreen(
        prefsService: prefsService,
        quizService: quizService,
      ),
    );
  }
}
