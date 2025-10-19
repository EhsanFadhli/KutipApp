
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/log_model.dart';
import 'package:myapp/log_service.dart';
import 'package:myapp/ui/widgets.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<LogEntry> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await LogService.getLogs();
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Action Logs', style: TextStyle(color: kPrimaryText)),
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedCard(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Actions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryText),
                    ),
                    const SizedBox(height: 16),
                    _logs.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.0),
                              child: Text(
                                'No logs found.',
                                style: TextStyle(color: kSubtleText, fontSize: 16),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                final parts = log.action.split(' - ');
                                final action = parts[0];
                                final amount = parts.length > 1 ? parts[1] : null;

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.history, color: kPrimaryBlue),
                                  title: Text(action, style: const TextStyle(color: kPrimaryText)),
                                  subtitle: Text(
                                    DateFormat.yMMMd().add_jm().format(log.timestamp),
                                    style: const TextStyle(color: kSubtleText),
                                  ),
                                  trailing: amount != null
                                      ? Text(
                                          amount,
                                          style: const TextStyle(
                                            color: kGreenAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                  ],
                ),
        ),
      ),
    );
  }
}
