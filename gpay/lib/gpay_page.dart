import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'qr_scanner_page.dart';
import 'history_screen.dart';
import 'services/auth_service.dart';

class GpayPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const GpayPage({super.key, required this.userData});

  @override
  State<GpayPage> createState() => _GpayPageState();
}

class _GpayPageState extends State<GpayPage> {
  bool _isCardVisible = false;

  void _toggleCardVisibility() async {
    if (_isCardVisible) {
      setState(() => _isCardVisible = false);
    } else {
      bool isAuthenticated = await AuthService.authenticateUser(
        context,
        widget.userData['email'],
      );
      if (isAuthenticated) {
        setState(() => _isCardVisible = true);
      }
    }
  }

  // --- NEW: Opens the Custom QR Dashboard directly ---
  void _showQrDashboard() {
    showDialog(
      context: context,
      builder: (context) => ReceiveQRDialog(userData: widget.userData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.userData['name'] ?? 'User';
    final String balance = widget.userData['balance']?.toString() ?? '0.00';

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        title: const Text('GPay'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Balance Card with QR Icon
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hello, $name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // --- THE TRIGGER BUTTON ---
                          IconButton(
                            icon: const Icon(
                              Icons.qr_code_2,
                              color: Colors.blueAccent,
                              size: 30,
                            ),
                            onPressed:
                                _showQrDashboard, // <--- Calls the new dialog
                            tooltip: "Show My QR",
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ $balance',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.qr_code_scanner, 'Scan QR', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QRScannerPage(userData: widget.userData),
                      ),
                    );
                  }),
                  _buildActionButton(Icons.history, 'History', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HistoryScreen(userData: widget.userData),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 40),

              // 3. My Cards Section
              const Text(
                "My Cards",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _toggleCardVisibility,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (_isCardVisible)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "FamX Card",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Icon(Icons.contactless, color: Colors.white),
                                ],
                              ),
                              const Text(
                                "4512  xxxx  xxxx  9821",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  letterSpacing: 2,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const Text(
                                    "EXP 12/28",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (!_isCardVisible)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock, color: Colors.white, size: 40),
                                SizedBox(height: 10),
                                Text(
                                  "Tap to View Details",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 4. People Section (NEW!)
              const Text(
                "People",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPersonAvatar("Alice", Colors.pinkAccent),
                    _buildPersonAvatar("Bob", Colors.orangeAccent),
                    _buildPersonAvatar("Carol", Colors.greenAccent),
                    _buildPersonAvatar("David", Colors.purpleAccent),
                    _buildPersonAvatar("Emma", Colors.tealAccent),
                    _buildPersonAvatar("Frank", Colors.blueAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blueAccent,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPersonAvatar(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Text(
              name[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ==========================================================
// NEW WIDGET: The Custom QR Dashboard (Pop-up Card)
// ==========================================================
class ReceiveQRDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ReceiveQRDialog({super.key, required this.userData});

  @override
  State<ReceiveQRDialog> createState() => _ReceiveQRDialogState();
}

class _ReceiveQRDialogState extends State<ReceiveQRDialog> {
  String? _customAmount;
  final GlobalKey _qrKey = GlobalKey();

  // Dialog to enter amount
  void _promptAmount() {
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Amount"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: "₹ ",
            hintText: "e.g. 500",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                setState(() {
                  _customAmount = amountController.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }

  // Share Logic
  Future<void> _shareQr() async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      String shareText = _customAmount != null
          ? "Pay me ₹$_customAmount via UPI\n${widget.userData['name']}"
          : "Send me money via UPI\n${widget.userData['name']}";

      await Share.shareXFiles([
        XFile.fromData(pngBytes, name: 'qr_code.png', mimeType: 'image/png'),
      ], text: shareText);
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construct UPI String dynamically
    String upiData =
        "upi://pay?pa=${widget.userData['email']}&pn=${Uri.encodeComponent(widget.userData['name'])}";
    if (_customAmount != null) {
      upiData += "&am=$_customAmount";
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Receive Money",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.userData['email'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 1. THE BIG QR (Red Area in your drawing)
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8), // Light grey/blue bg
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: upiData,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: const Color(0xFFF0F4F8),
                ),
              ),
            ),

            const SizedBox(height: 10),
            if (_customAmount != null)
              Text(
                "Requesting ₹$_customAmount",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

            const SizedBox(height: 30),

            // 2. BUTTONS ROW (Matches your drawing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "Enter Amount" (Left Side - Pill shape)
                Expanded(
                  child: InkWell(
                    onTap: _promptAmount,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _customAmount == null ? "Set Amount" : "Change",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // "Share" (Right Side - Circle/Icon)
                InkWell(
                  onTap: _shareQr,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
