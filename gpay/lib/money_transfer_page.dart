import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'gpay_page.dart';

class MoneyTransferPage extends StatefulWidget {
  final String upiId;
  final Map<String, dynamic> userData;

  const MoneyTransferPage({
    super.key,
    required this.upiId,
    required this.userData,
  });

  @override
  State<MoneyTransferPage> createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> {
  String _amount = '0';
  String _selectedName = "Merchant";
  String _selectedAvatar = "M";
  String _displayUpiId = "";
  final TextEditingController _noteController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _parseUpiData();
  }

  void _parseUpiData() {
    Uri? uri = Uri.tryParse(widget.upiId);

    if (uri != null && uri.scheme == 'upi') {
      String name = uri.queryParameters['pn'] ?? 'Unknown Merchant';
      String upiId = uri.queryParameters['pa'] ?? widget.upiId;
      name = Uri.decodeComponent(name);

      setState(() {
        _selectedName = name.isEmpty ? "Merchant" : name;
        _displayUpiId = upiId;
        _selectedAvatar = _selectedName[0].toUpperCase();
      });
    } else {
      setState(() {
        _displayUpiId = widget.upiId;
        if (widget.upiId.startsWith('http')) {
          _selectedName = "External Merchant";
          _selectedAvatar = "E";
        } else {
          _selectedName = "Unknown Receiver";
          _selectedAvatar = "?";
        }
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_amount == '0') {
        _amount = number;
      } else {
        _amount += number;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (!_amount.contains('.')) {
        _amount += '.';
      }
    });
  }

  void _setPresetAmount(int amount) {
    setState(() {
      _amount = amount.toString();
    });
  }

  Future<void> _processPayment() async {
    if (_amount == '0' || _amount.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter an amount')));
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    const String url = 'http://192.168.31.97:3000/pay';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': _amount,
          'receiver_name': _selectedName,
          'upi_id': _displayUpiId,
          'sender_email': widget.userData['email'],
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final updatedBalance =
            (double.parse(widget.userData['balance'].toString()) -
                    double.parse(_amount))
                .toStringAsFixed(2);

        final updatedUserData = Map<String, dynamic>.from(widget.userData);
        updatedUserData['balance'] = updatedBalance;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment of ₹$_amount successful!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GpayPage(userData: updatedUserData),
          ),
          (route) => false,
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Payment failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String senderName = widget.userData['name'] ?? 'User';
    final String senderBalance =
        widget.userData['balance']?.toString() ?? '0.00';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 166, 203, 234),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Paying $_selectedName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _displayUpiId,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blueAccent.withOpacity(0.12),
                      child: Text(
                        _selectedAvatar,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          _amount,
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _noteController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Add a note',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPresetAmountChip('₹100', 100),
                        const SizedBox(width: 12),
                        _buildPresetAmountChip('₹500', 500),
                        const SizedBox(width: 12),
                        _buildPresetAmountChip('₹1000', 1000),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From $senderName',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹$senderBalance',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Pay"),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _buildNumberRow(['1', '2', '3']),
                  _buildNumberRow(['4', '5', '6']),
                  _buildNumberRow(['7', '8', '9']),
                  _buildNumberRow(['.', '0', '⌫']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        return InkWell(
          onTap: () => number == '⌫'
              ? _onBackspace()
              : (number == '.'
                    ? _onDecimalPressed()
                    : _onNumberPressed(number)),
          child: Container(
            width: 80,
            height: 50,
            alignment: Alignment.center,
            child: number == '⌫'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: Colors.blueAccent,
                    size: 20,
                  )
                : Text(
                    number,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPresetAmountChip(String label, int amount) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () => _setPresetAmount(amount),
      backgroundColor: Colors.white,
    );
  }
}
