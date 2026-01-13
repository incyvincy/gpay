import 'package:flutter/material.dart';

class MoneyTransferPage extends StatefulWidget {
  final String upiId;

  const MoneyTransferPage({super.key, required this.upiId});

  @override
  State<MoneyTransferPage> createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> {
  String _amount = '0';
  String _selectedName = "MERCHANT";
  String _selectedAvatar = "M";
  String _displayUpiId = "";
  final double _balance = 12500.50;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parseUpiData();
  }

  void _parseUpiData() {
    Uri? uri = Uri.tryParse(widget.upiId);

    if (uri != null && uri.queryParameters.containsKey('pa')) {
      String name = uri.queryParameters['pn'] ?? 'Unknown Merchant';
      String upiId = uri.queryParameters['pa'] ?? widget.upiId;

      // Fix URL encoding (spaces often come as %20)
      name = Uri.decodeComponent(name);

      setState(() {
        _selectedName = name.isEmpty ? "Merchant" : name;
        _displayUpiId = upiId;
        _selectedAvatar = _selectedName.isNotEmpty
            ? _selectedName[0].toUpperCase()
            : "M";
      });
    } else {
      setState(() {
        _displayUpiId = widget.upiId;
        final idParts = widget.upiId.split('@');
        final base = idParts.isNotEmpty ? idParts[0] : widget.upiId;
        _selectedName = _formatName(base);
        _selectedAvatar = _selectedName.isNotEmpty
            ? _selectedName[0].toUpperCase()
            : "U";
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatName(String name) {
    name = name.replaceAll(RegExp(r'[._-]'), ' ');
    return name
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
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

  void _showPaymentSuccess() {
    if (_amount == '0' || _amount.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    // Simple Snack bar for now - you can wire this to Backend later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing Payment...'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 166, 203, 234),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar (Close Button)
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 2. Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Recipient Info
                    Column(
                      children: [
                        Text(
                          'Paying $_selectedName',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _displayUpiId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Avatar
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
                      ],
                    ),

                    const SizedBox(height: 30),

                    // AMOUNT DISPLAY
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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

                    // NOTE FIELD
                    Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _noteController,
                        style: const TextStyle(color: Colors.black87),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Add a note',
                          hintStyle: TextStyle(color: Colors.black45),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PRESET BUTTONS (Fixed Colors)
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

            // 3. Compact Keypad Area (white card)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Account Info Row
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
                            const Text(
                              'From Bivesh Kumar Account',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹$_balance',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Small Pay Button (primary)
                        ElevatedButton(
                          onPressed: _showPaymentSuccess,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Pay"),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.black12, height: 1),

                  // KEYPAD
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: numbers.map((number) {
          return InkWell(
            onTap: () {
              if (number == '⌫')
                _onBackspace();
              else if (number == '.')
                _onDecimalPressed();
              else
                _onNumberPressed(number);
            },
            borderRadius: BorderRadius.circular(40),
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
      ),
    );
  }

  Widget _buildPresetAmountChip(String label, int amount) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.blueAccent, // Blue Text
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      onPressed: () => _setPresetAmount(amount),
      backgroundColor: Colors.white, // White Background
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
