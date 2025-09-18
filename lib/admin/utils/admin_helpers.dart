import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sharpcuts/admin/utils/create_admin.dart';
import 'package:sharpcuts/routes/app_routes.dart';

// This is a utility function to be called from anywhere in the app
// to create an admin account directly
Future<void> createAdminAccount(BuildContext context) async {
  try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating admin account...'),
          ],
        ),
      ),
    );

    // Create admin account
    final result = await CreateAdminUtil.createAdminAccount(
      email: 'admin@gmail.com',
      password: '123456',
      name: 'Admin User',
    );

    // Close loading dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Show result
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to admin login
      Get.offAllNamed(AppRoutes.adminLogin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin account already exists or an error occurred'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    // Close loading dialog if open
    Navigator.of(context, rootNavigator: true).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}