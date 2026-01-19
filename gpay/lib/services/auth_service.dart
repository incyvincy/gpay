// lib/auth_service.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_constants.dart';

class AuthService {
  static Future<bool> authenticateUser(
    BuildContext context,
    String email,
  ) async {
    // Authenticate using password
    return await _showPasswordDialog(context, email);
  }

  static Future<bool> _showPasswordDialog(
    BuildContext context,
    String email,
  ) async {
    String password = '';
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Enter Password'),
              content: TextField(
                obscureText: true,
                onChanged: (value) => password = value,
                decoration: const InputDecoration(
                  hintText: 'Your account password',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Verify password with backend
                    final isValid = await _verifyPasswordWithBackend(
                      email,
                      password,
                    );
                    if (context.mounted) Navigator.pop(context, isValid);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Future<bool> _verifyPasswordWithBackend(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
