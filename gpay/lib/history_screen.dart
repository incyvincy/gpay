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
  List<dynamic> _filteredTransactions = [];
  bool _isLoading = true;

  // Filter state
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _filteredTransactions = data['transactions'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      final myEmail = widget.userData['email'];

      _filteredTransactions = _transactions.where((txn) {
        // Filter by category
        bool matchesCategory = true;
        if (_selectedFilter == 'Received') {
          matchesCategory = txn['receiver_email'] == myEmail;
        } else if (_selectedFilter == 'Sent') {
          matchesCategory = txn['sender_email'] == myEmail;
        }

        // Filter by search query
        if (query.isEmpty) return matchesCategory;

        final receiverName = (txn['receiver_name'] ?? '').toLowerCase();
        final upiId = (txn['upi_id'] ?? '').toLowerCase();
        final senderEmail = (txn['sender_email'] ?? '').toLowerCase();
        final remark = (txn['remark'] ?? '').toLowerCase();

        final matchesSearch =
            receiverName.contains(query) ||
            upiId.contains(query) ||
            senderEmail.contains(query) ||
            remark.contains(query);

        return matchesCategory && matchesSearch;
      }).toList();
    });
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
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, UPI ID, phone, or note',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Filter Chips
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Received'),
                      _buildFilterChip('Sent'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Transaction List
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final txn = _filteredTransactions[index];
                            final myEmail = widget.userData['email'];

                            // Logic: Did I send it or receive it?
                            final bool isSent = txn['sender_email'] == myEmail;
                            final bool isReceived =
                                txn['receiver_email'] == myEmail;

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
                                    isSent
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: color,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/transaction_detail',
                                    arguments: {
                                      'id': (txn['id'] ?? 'N/A').toString(),
                                      'amount': txn['amount'].toString(),
                                      'name': txn['receiver_name'] ?? 'Unknown',
                                      'date': txn['date']?.toString() ?? 'N/A',
                                      'status': isSent ? 'Sent' : 'Received',
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
            _applyFilters();
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blueAccent,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
