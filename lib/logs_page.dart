import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kutip/log_model.dart';
import 'package:kutip/log_service.dart';
import 'package:kutip/ui/widgets.dart';

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
                    _logs.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.0),
                              child: Text(
                                'No logs found.',
                                style: TextStyle(
                                  color: kSubtleText,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                final parts = log.action.split(' - ');
                                String action = parts[0];
                                final String? amount = parts.length > 1
                                    ? parts[1]
                                    : null;

                                Color amountColor =
                                    kGreenAccent; // Default color
                                Widget? trailing;

                                bool isArchive = action.contains('Archived');
                                bool isSetFee = action.contains(
                                  'Set monthly fee',
                                );

                                if (isArchive) {
                                  amountColor = kAccentRed;
                                }

                                if (isSetFee && amount != null) {
                                  action = 'Monthly Fee Set to $amount';
                                  trailing =
                                      null; // Remove trailing widget for this specific log
                                } else if (amount != null) {
                                  trailing = Text(
                                    amount,
                                    style: TextStyle(
                                      color: amountColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );
                                }

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  leading: const Icon(
                                    Icons.history,
                                    color: kPrimaryBlue,
                                  ),
                                  title: Text(
                                    action,
                                    style: const TextStyle(color: kPrimaryText),
                                  ),
                                  subtitle: Text(
                                    DateFormat.yMMMd().add_jm().format(
                                      log.timestamp,
                                    ),
                                    style: const TextStyle(color: kSubtleText),
                                  ),
                                  trailing: trailing,
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                color: kSubtleText.withAlpha(51),
                                height: 1,
                              ),
                            ),
                          ),
                  ],
                ),
        ),
      ),
    );
  }
}
