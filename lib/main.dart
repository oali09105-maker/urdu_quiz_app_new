import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UrduQuizApp());
}

class UrduQuizApp extends StatelessWidget {
  const UrduQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اردو کوئز گیم',
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
      home: const QuizHomePage(),
    );
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  List<dynamic> questionsList = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoading = true;
  int? selectedOption;
  bool isAnswered = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadQuestionsJson();
  }

  Future<void> loadQuestionsJson() async {
    try {
      final String jsonContent =
          await rootBundle.loadString('assets/quiz_data_3000.json');
      final List<dynamic> parsedData = json.decode(jsonContent);

      setState(() {
        questionsList = parsedData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'فائل لوڈ کرنے میں مسئلہ ہوا: $e';
        isLoading = false;
      });
    }
  }

  void onOptionSelected(int optionIndex, dynamic answerValue) {
    if (isAnswered) return;

    setState(() {
      selectedOption = optionIndex;
      isAnswered = true;

      bool isCorrect = false;
      if (answerValue is int && answerValue == optionIndex) {
        isCorrect = true;
      } else if (answerValue is String) {
        String optionText =
            questionsList[currentIndex]['option$optionIndex']?.toString() ?? '';
        if (optionText.trim() == answerValue.trim()) {
          isCorrect = true;
        }
      }

      if (isCorrect) {
        score += 10;
      }
    });
  }

  void goToNextQuestion() {
    if (currentIndex + 1 < questionsList.length) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        isAnswered = false;
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('🎉 مبارک ہو! کوئز مکمل', textAlign: TextAlign.center),
          content: Text(
            'آپ نے کل $score اسکور حاصل کیا۔',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    currentIndex = 0;
                    score = 0;
                    selectedOption = null;
                    isAnswered = false;
                  });
                },
                child: const Text('دوبارہ کھیلیں'),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 16),
              Text('سوالات لوڈ ہو رہے ہیں...', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty || questionsList.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              errorMessage.isNotEmpty ? errorMessage : 'کوئی سوال نہیں ملا!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final currentQ = questionsList[currentIndex];
    final dynamic correctAnswer = currentQ['answer'];

    return Scaffold(
      appBar: AppBar(
        title: Text('سوال: ${currentIndex + 1} / ${questionsList.length}'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                'اسکور: $score',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
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
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  currentQ['question']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (int i = 1; i <= 4; i++) ...[
                      Builder(
                        builder: (context) {
                          final optText =
                              currentQ['option$i']?.toString() ?? '';
                          if (optText.isEmpty) return const SizedBox.shrink();

                          Color btnBgColor = const Color(0xFF1E293B);
                          Color borderColor = const Color(0xFF334155);

                          if (isAnswered) {
                            bool isThisTheCorrectOne = false;
                            if (correctAnswer is int && correctAnswer == i) {
                              isThisTheCorrectOne = true;
                            } else if (correctAnswer is String &&
                                correctAnswer.trim() == optText.trim()) {
                              isThisTheCorrectOne = true;
                            }

                            if (isThisTheCorrectOne) {
                              btnBgColor = Colors.green.shade800;
                              borderColor = Colors.greenAccent;
                            } else if (selectedOption == i) {
                              btnBgColor = Colors.red.shade800;
                              borderColor = Colors.redAccent;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () => onOptionSelected(i, correctAnswer),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: btnBgColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.black26,
                                      child: Text(
                                        '$i',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        optText,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              if (isAnswered)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: goToNextQuestion,
                    child: const Text(
                      'اگلا سوال  ⬅',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
