import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// This utility class is used to create an admin account in Firestore
class CreateAdminUtil {
  static Future<bool> createAdminAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Reference to the Admin collection
      final adminCollection = FirebaseFirestore.instance.collection('Admin');
      
      // Check if admin with this email already exists
      final existingAdmin = await adminCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (existingAdmin.docs.isNotEmpty) {
        debugPrint('Admin with email $email already exists');
        return false;
      }
      
      // Create new admin document
      await adminCollection.add({
        'email': email,
        'password': password,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Admin account created successfully for $email');
      return true;
    } catch (e) {
      debugPrint('Error creating admin account: $e');
      return false;
    }
  }
}