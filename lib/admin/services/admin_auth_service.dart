import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sharpcuts/routes/app_routes.dart';

class AdminAuthService {
  // Logout method for admin
  static void logoutAdmin(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close dialog
                Navigator.of(dialogContext).pop();
                
                // Navigate directly to login screen without showing loading dialog
                // This avoids the issues with disposed contexts
                Get.offAllNamed(AppRoutes.login);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}