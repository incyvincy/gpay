// lib/history_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/api_constants.dart';

class HistoryScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HistoryScreen({super.key, required this.userData});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.history),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.userData['email']}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _transactions = data['transactions'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final txn = _transactions[index];
                final myEmail = widget.userData['email'];

                // Logic: Did I send it or receive it?
                final bool isSent = txn['sender_email'] == myEmail;
                final bool isReceived = txn['receiver_email'] == myEmail;

                // Formatting
                final color = isSent ? Colors.red : Colors.green;
                final sign = isSent ? '-' : '+';
                final name = isSent
                    ? "To: ${txn['receiver_name']}"
                    : "From: ${txn['sender_email']}";

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(
                        isSent ? Icons.arrow_upward : Icons.arrow_downward,
                        color: color,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      txn['date']?.toString().substring(0, 10) ??
                          'Unknown Date',
                    ),
                    trailing: Text(
                      "$sign ₹${txn['amount']}",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
