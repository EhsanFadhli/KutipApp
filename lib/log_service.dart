
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/log_model.dart';

class LogService {
  static const String _logKey = 'app_logs';

  static Future<void> logAction(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logsJson = prefs.getStringList(_logKey) ?? [];
    
    final newLog = LogEntry(action: action, timestamp: DateTime.now());
    logsJson.add(newLog.toJson());
    
    await prefs.setStringList(_logKey, logsJson);
  }

  static Future<List<LogEntry>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logsJson = prefs.getStringList(_logKey) ?? [];
    
    final List<LogEntry> logs = logsJson.map((log) => LogEntry.fromJson(log)).toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by most recent
    
    return logs;
  }
}
