import 'package:flutter/material.dart';
import 'package:sharpcuts/constants/app_colors.dart';
import 'package:sharpcuts/routes/app_routes.dart';
import 'package:sharpcuts/user/controllers/auth_controller.dart';

class UserAuthService {
  // Logout method for user
  static void logoutUser(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.primaryColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: AppColors.textColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.lightTextColor,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardColor,
                foregroundColor: AppColors.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Close dialog
                Navigator.of(dialogContext).pop();
                
                // Call logout from AuthController
                AuthController.instance.logout();
                
                // Use standard Navigator API to avoid any default dialogs
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login, 
                  (route) => false
                );
              },
              child: const Text(
                'Yes, Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}