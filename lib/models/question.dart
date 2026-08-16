class Question {
  final String id;
  final String category;
  final String level; // 'E', 'M', 'H'
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer; // 'A', 'B', 'C', 'D'
  final String explanation;
  final String tags;

  Question({
    required this.id,
    required this.category,
    required this.level,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.explanation,
    required this.tags,
  });

  factory Question.fromCsvRow(List<dynamic> row) {
    return Question(
      id: row[0].toString().trim(),
      category: row[1].toString().trim(),
      level: row[2].toString().trim(),
      question: row[3].toString().trim(),
      optionA: row[4].toString().trim(),
      optionB: row[5].toString().trim(),
      optionC: row[6].toString().trim(),
      optionD: row[7].toString().trim(),
      correctAnswer: row[8].toString().trim().toUpperCase(),
      explanation: row[9].toString().trim(),
      tags: row.length > 10 ? row[10].toString().trim() : '',
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    String ans = json['correctAnswer'] ?? json['answer'] ?? 'A';
    if (ans.length > 1) {
      ans = ans.substring(0, 1).toUpperCase();
    }
    return Question(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      level: json['level']?.toString() ?? 'E',
      question: json['question']?.toString() ?? '',
      optionA: json['option1']?.toString() ?? json['optionA']?.toString() ?? '',
      optionB: json['option2']?.toString() ?? json['optionB']?.toString() ?? '',
      optionC: json['option3']?.toString() ?? json['optionC']?.toString() ?? '',
      optionD: json['option4']?.toString() ?? json['optionD']?.toString() ?? '',
      correctAnswer: ans,
      explanation: json['explanation']?.toString() ?? '',
      tags: json['tags']?.toString() ?? '',
    );
  }

  String getOptionByLetter(String letter) {
    switch (letter.toUpperCase()) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return '';
    }
  }
}
