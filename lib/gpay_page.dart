import 'package:flutter/material.dart';

class GpayPage extends StatefulWidget {
  const GpayPage({super.key});

  @override
  State<GpayPage> createState() => _GpayPageState();
}

class _GpayPageState extends State<GpayPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample transaction data
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': 'TXN001',
      'name': 'John Doe',
      'status': 'Sent',
      'amount': 150,
      'date': 'Jan 12, 2026',
    },
    {
      'id': 'TXN002',
      'name': 'Alice Smith',
      'status': 'Received',
      'amount': 250,
      'date': 'Jan 11, 2026',
    },
    {
      'id': 'TXN003',
      'name': 'Bob Johnson',
      'status': 'Sent',
      'amount': 100,
      'date': 'Jan 10, 2026',
    },
    {
      'id': 'TXN004',
      'name': 'Charlie Brown',
      'status': 'Failed',
      'amount': 300,
      'date': 'Jan 9, 2026',
    },
    {
      'id': 'TXN005',
      'name': 'Diana Prince',
      'status': 'Received',
      'amount': 500,
      'date': 'Jan 8, 2026',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    var filtered = _allTransactions;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((txn) => txn['status'] == _selectedFilter)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (txn) =>
                txn['name'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                txn['id'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        title: const Text('GPay'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Balance', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 8),
                    Text(
                      '₹ 1,234.56',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(label: 'Send'),
                _ActionButton(label: 'Request'),
                _ActionButton(label: 'Pay'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/scanner');
              },
              child: const Text('Scan any QR code'),
            ),
            const SizedBox(height: 24),
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Received'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Sent'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Failed'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_filteredTransactions.length} results',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, i) {
                        final txn = _filteredTransactions[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(txn['status']),
                              child: Text(
                                txn['name'][0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              txn['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${txn['status']} • ${txn['date']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              '${txn['status'] == 'Received' ? '+' : '-'} ₹${txn['amount']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: txn['status'] == 'Received'
                                    ? Colors.green
                                    : txn['status'] == 'Failed'
                                    ? Colors.red
                                    : Colors.black87,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/transaction_detail',
                                arguments: txn,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Received':
        return Colors.green;
      case 'Sent':
        return Colors.blueAccent;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  const _ActionButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => debugPrint('GPay action: $label'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Text(label),
    );
  }
}
