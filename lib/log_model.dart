
import 'dart:convert';

class LogEntry {
  final String action;
  final DateTime timestamp;

  LogEntry({required this.action, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      action: map['action'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory LogEntry.fromJson(String source) => LogEntry.fromMap(json.decode(source));
}
