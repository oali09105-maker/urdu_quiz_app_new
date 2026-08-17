import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuizService {
  List<Question> _allQuestions = [];

  bool get isLoaded => _allQuestions.isNotEmpty;

  Future<void> loadQuestions() async {
    if (_allQuestions.isNotEmpty) return;

    try {
      final String csvString =
          await rootBundle.loadString('assets/Final_UrduQuiz_3000.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvString,
        eol: '\n',
        shouldParseNumbers: false,
      );

      if (csvTable.isNotEmpty) {
        // Skip header row if present
        int startIndex = 0;
        if (csvTable[0][0].toString().contains('ID')) {
          startIndex = 1;
        }

        for (int i = startIndex; i < csvTable.length; i++) {
          var row = csvTable[i];
          if (row.length >= 9) {
            _allQuestions.add(Question.fromCsvRow(row));
          }
        }
      }
    } catch (e) {
      // Fallback to json if csv parsing fails
      try {
        final String jsonContent =
            await rootBundle.loadString('assets/quiz_data_3000.json');
        final List<dynamic> parsedData = json.decode(jsonContent);
        _allQuestions = parsedData.map((e) => Question.fromJson(e)).toList();
      } catch (_) {}
    }
  }

  List<Question> getAllQuestions() => _allQuestions;

  // Level 1: Easy Q1-Q1000, Level 2: Medium Q1001-Q2000, Level 3: Hard Q2001-Q3000
  List<Question> getQuestionsByLevel(int level, {String? category}) {
    List<Question> levelQuestions = [];

    if (level == 1) {
      // Easy Q1 - Q1000
      levelQuestions = _allQuestions.where((q) {
        int idNum = _parseIdNumber(q.id);
        return idNum >= 1 && idNum <= 1000;
      }).toList();
    } else if (level == 2) {
      // Medium Q1001 - Q2000
      levelQuestions = _allQuestions.where((q) {
        int idNum = _parseIdNumber(q.id);
        return idNum >= 1001 && idNum <= 2000;
      }).toList();
    } else if (level == 3) {
      // Hard Q2001 - Q3000
      levelQuestions = _allQuestions.where((q) {
        int idNum = _parseIdNumber(q.id);
        return idNum >= 2001 && idNum <= 3000;
      }).toList();
    } else {
      levelQuestions = List.from(_allQuestions);
    }

    if (category != null && category.isNotEmpty && category != 'All') {
      levelQuestions = levelQuestions.where((q) {
        return q.category.contains(category) || category.contains(q.category);
      }).toList();
    }

    return levelQuestions;
  }

  int _parseIdNumber(String idStr) {
    String cleanStr = idStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  static const List<Map<String, String>> categoriesList = [
    {'name': '99% Galat', 'urdu': '🧠 99٪ لوگ غلط جواب دیتے ہیں'},
    {'name': 'Trick', 'urdu': '😈 ٹرک سوالات'},
    {'name': 'Dimagh', 'urdu': '🤯 دماغ کا امتحان'},
    {'name': 'Muhavre', 'urdu': '📖 اردو محاورے'},
    {'name': 'Paheliyan', 'urdu': '🧩 دلچسپ پہیلیاں'},
    {'name': 'Alfaaz', 'urdu': '🎭 الفاظ کا جادو'},
    {'name': '5 Second', 'urdu': '⏳ 5 سیکنڈ چیلنج'},
    {'name': 'Zaheen', 'urdu': '👑 صرف ذہین لوگوں کے لیے'},
  ];
}
