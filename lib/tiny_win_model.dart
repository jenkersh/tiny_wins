import 'dart:convert';

class TinyWin {
  final DateTime date;
  final String message;

  TinyWin({required this.date, required this.message});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'message': message,
    };
  }

  factory TinyWin.fromMap(Map<String, dynamic> map) {
    return TinyWin(
      date: DateTime.parse(map['date']),
      message: map['message'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TinyWin.fromJson(String source) => TinyWin.fromMap(json.decode(source));
}
