import 'package:flutter_test/flutter_test.dart';
import 'package:urdu_quiz_app/main.dart';
import 'package:urdu_quiz_app/services/preferences_service.dart';
import 'package:urdu_quiz_app/services/quiz_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final prefsService = PreferencesService();
    final quizService = QuizService();

    await tester.pumpWidget(UrduQuizApp(
      prefsService: prefsService,
      quizService: quizService,
    ));

    expect(find.text('اردو الفاظ'), findsOneWidget);
  });
}
