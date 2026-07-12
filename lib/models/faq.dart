// To parse this JSON data, do
//
//     final faq = faqFromJson(jsonString);

import 'dart:convert';

Faq faqFromJson(String str) => Faq.fromJson(json.decode(str));

String faqToJson(Faq data) => json.encode(data.toJson());

class Faq {
  Faq({
    required this.faq,
  });

  List<FaqElement> faq;

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
    faq: List<FaqElement>.from(json["faq"].map((x) => FaqElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "faq": List<dynamic>.from(faq.map((x) => x.toJson())),
  };
}

class FaqElement {
  FaqElement({
    required this.question,
    required this.answer,
  });

  String question;
  String answer;

  factory FaqElement.fromJson(Map<String, dynamic> json) => FaqElement(
    question: json["question"],
    answer: json["answer"],
  );

  Map<String, dynamic> toJson() => {
    "question": question,
    "answer": answer,
  };
}
