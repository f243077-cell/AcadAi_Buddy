import 'package:study_ai_app/domain/study/entities/quiz_message.dart';

class QuizQuestionDto {
  final String question;
  final List<String> options;
  final String answer;

  const QuizQuestionDto({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestionDto.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final List<String> parsedOptions;

    if (rawOptions is List) {
      parsedOptions = rawOptions.map((e) => e.toString()).toList();
    } else {
      parsedOptions = [];
    }

    return QuizQuestionDto(
      question: json['question'] as String,
      options: parsedOptions,
      answer: json['answer'] as String,
    );
  }

  QuizQuestion toDomain() {
    return QuizQuestion(
      question: question,
      options: options,
      answer: answer,
    );
  }
}
