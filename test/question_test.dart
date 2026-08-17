import 'package:flutter_test/flutter_test.dart';
import 'package:urdu_quiz_app/models/question.dart';

void main() {
  group('Question model & logic test', () {
    test('Question.fromCsvRow parses row correctly', () {
      final row = [
        'Q0001',
        '⏳ 5 سیکنڈ چیلنج',
        'E',
        'پاکستان کا رقبہ کتنا ہے',
        '796096',
        '881913',
        '900000',
        '750000',
        'A',
        'پاکستان کا کل رقبہ 796,096 مربع کلومیٹر ہے۔',
        '5 سیکنڈ چیلنج, آسان'
      ];

      final q = Question.fromCsvRow(row);
      expect(q.id, 'Q0001');
      expect(q.category, '⏳ 5 سیکنڈ چیلنج');
      expect(q.level, 'E');
      expect(q.correctAnswer, 'A');
      expect(q.getOptionByLetter('A'), '796096');
    });
  });
}
