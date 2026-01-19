import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get transaction data from arguments
    final transaction =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (transaction == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAF6FF),
        appBar: AppBar(
          title: const Text('Transaction Details'),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(child: Text('No transaction data available')),
      );
    }

    final String status = transaction['status'] ?? 'Completed';
    final bool isSuccess = status != 'Failed';

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        title: const Text('Payment Receipt'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Success/Failed Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuccess ? Icons.check_circle : Icons.cancel,
                          size: 70,
                          color: isSuccess ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Status Text
                      Text(
                        isSuccess ? 'Payment Successful!' : 'Payment Failed',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSuccess ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Amount
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${transaction['amount']}',
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Transaction Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transaction Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              'Receiver',
                              transaction['name'] ?? 'Unknown',
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(
                              'Transaction ID',
                              transaction['id'] ?? 'N/A',
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(
                              'Date & Time',
                              transaction['date'] ?? 'N/A',
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(
                              'Status',
                              status,
                              statusColor: isSuccess
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            if (status == 'Sent' || status == 'Received')
                              const Divider(height: 24),
                            if (status == 'Sent' || status == 'Received')
                              _buildDetailRow(
                                'Type',
                                status,
                                statusColor: status == 'Received'
                                    ? Colors.green
                                    : Colors.blueAccent,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action Buttons at bottom
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _shareReceipt(context, transaction);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text(
                    'Share Receipt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: statusColor ?? Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _shareReceipt(BuildContext context, Map<String, dynamic> transaction) {
    final receiptText =
        '''
Payment Receipt
------------------
Amount: ₹${transaction['amount']}
Receiver: ${transaction['name']}
Transaction ID: ${transaction['id']}
Date: ${transaction['date']}
Status: ${transaction['status']}
------------------
Paid via QuickPay
    ''';

    Share.share(
      receiptText,
      subject: 'Payment Receipt - ₹${transaction['amount']}',
    );
  }
}
