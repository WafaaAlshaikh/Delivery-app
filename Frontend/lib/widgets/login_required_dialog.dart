// lib/widgets/login_required_dialog.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/signup_screen.dart';

void showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Login required',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'You need to log in or create an account before adding items to your cart.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
          },
          child: const Text('Log in / Sign up'),
        ),
      ],
    ),
  );
}
