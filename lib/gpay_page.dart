import 'package:flutter/material.dart';

class GpayPage extends StatelessWidget {
  const GpayPage({super.key});

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
            const SizedBox(height: 24),
            const Text(
              'Recent',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, i) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Transaction ${i + 1}'),
                  subtitle: const Text('To: Example'),
                  trailing: Text('- ₹ ${(i + 1) * 50}'),
                  onTap: () => debugPrint('Tapped transaction ${i + 1}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
