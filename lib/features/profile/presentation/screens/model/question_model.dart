import 'dart:convert';

List<QuestionModel> questionModelFromJson(String str) =>
    List<QuestionModel>.from(json.decode(str).map((x) => QuestionModel.fromJson(x)));

String questionModelToJson(List<QuestionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class QuestionModel {
  int id;
  Question question;
  Answer answer;

  QuestionModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json["id"] ?? 0,
        question: Question.fromJson(json["question"] ?? {}),
        answer: Answer.fromJson(json["answer"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question.toJson(),
        "answer": answer.toJson(),
      };
}

class Question {
  String en;
  String ar;

  Question({
    required this.en,
    required this.ar,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        en: json["en"] ?? '',
        ar: json["ar"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "en": en,
        "ar": ar,
      };
}

class Answer {
  String en;
  String ar;

  Answer({
    required this.en,
    required this.ar,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        en: json["en"] ?? '',
        ar: json["ar"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "en": en,
        "ar": ar,
      };
}
