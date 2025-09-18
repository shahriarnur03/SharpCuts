import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBooking(String serviceName, String userId) async {
    try {
      // Get the current Firebase user to ensure we have the email and name
      final currentUser = FirebaseAuth.instance.currentUser;
      String userEmail = currentUser?.email ?? '';
      String userName = currentUser?.displayName ?? 'User'; // Default to 'User' if no display name
      
      debugPrint("Firebase Auth user: email=$userEmail, name=$userName, uid=$userId");
      
      // Get user details from the users collection
      final userDoc = await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = {};
      
      if (userDoc.exists && userDoc.data() != null) {
        userData = userDoc.data()!;
        debugPrint("Found user data in Firestore: ${userData.toString()}");
      } else {
        debugPrint("No user document found in Firestore for ID: $userId");
        
        // If user document doesn't exist, create it now with data from Firebase Auth
        if (currentUser != null) {
          userData = {
            "Name": userName,
            "Email": userEmail,
            "Phone": "",
            "CreatedAt": DateTime.now().millisecondsSinceEpoch,
            "LastUpdated": DateTime.now().millisecondsSinceEpoch,
          };
          
          // Save the user data to Firestore
          await _firestore.collection('users').doc(userId).set(userData);
          debugPrint("Created new user document in Firestore with data: $userData");
        }
      }
      
      // Default date and time if not provided
      String date = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
      String time = '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
      
      // Safely get the name with fallbacks
      String nameToUse = userData['Name'] ?? userName;
      if (nameToUse.isEmpty || nameToUse == 'User') {
        // If name is still empty or default, try to extract a name from the email
        if (userEmail.isNotEmpty && userEmail.contains('@')) {
          nameToUse = userEmail.split('@')[0]; // Use part before @ as name
          debugPrint("Using name extracted from email: $nameToUse");
        } else {
          nameToUse = "Customer"; // Final fallback
        }
      }
      
      // Create booking with all fields required by admin dashboard
      final bookingData = {
        'Service': serviceName,
        'Name': nameToUse, // Use the determined name
        'Email': userData['Email'] ?? userEmail, // Use Auth email as backup
        'Phone': userData['Phone'] ?? '',
        'Date': date,
        'Time': time,
        'Status': 'Pending',
        'CreatedAt': FieldValue.serverTimestamp(),
        'IsTestData': false,
        'userId': userId,
      };
      
      debugPrint("Adding booking with data: $bookingData");
      
      await _firestore.collection('Booking').add(bookingData);
      
      debugPrint('Booking added to Booking collection with proper fields');
      
      Get.snackbar(
        'Success',
        'Booking added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error adding booking: $e');
      Get.snackbar(
        'Error',
        'Failed to add booking: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> addBookingWithDateTime(String serviceName, String userId, String date, String time) async {
    try {
      // Get the current Firebase user to ensure we have the email and name
      final currentUser = FirebaseAuth.instance.currentUser;
      String userEmail = currentUser?.email ?? '';
      String userName = currentUser?.displayName ?? 'User'; // Default to 'User' if no display name
      
      debugPrint("Firebase Auth user: email=$userEmail, name=$userName, uid=$userId");
      
      // Get user details from the users collection
      final userDoc = await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = {};
      
      if (userDoc.exists && userDoc.data() != null) {
        userData = userDoc.data()!;
        debugPrint("Found user data in Firestore: ${userData.toString()}");
      } else {
        debugPrint("No user document found in Firestore for ID: $userId");
        
        // If user document doesn't exist, create it now with data from Firebase Auth
        if (currentUser != null) {
          userData = {
            "Name": userName,
            "Email": userEmail,
            "Phone": "",
            "CreatedAt": DateTime.now().millisecondsSinceEpoch,
            "LastUpdated": DateTime.now().millisecondsSinceEpoch,
          };
          
          // Save the user data to Firestore
          await _firestore.collection('users').doc(userId).set(userData);
          debugPrint("Created new user document in Firestore with data: $userData");
        }
      }
      
      // Safely get the name with fallbacks
      String nameToUse = userData['Name'] ?? userName;
      if (nameToUse.isEmpty || nameToUse == 'User') {
        // If name is still empty or default, try to extract a name from the email
        if (userEmail.isNotEmpty && userEmail.contains('@')) {
          nameToUse = userEmail.split('@')[0]; // Use part before @ as name
          debugPrint("Using name extracted from email: $nameToUse");
        } else {
          nameToUse = "Customer"; // Final fallback
        }
      }
      
      // Create booking with all fields required by admin dashboard
      final bookingData = {
        'Service': serviceName,
        'Name': nameToUse, // Use the determined name
        'Email': userData['Email'] ?? userEmail, // Use Auth email as backup
        'Phone': userData['Phone'] ?? '',
        'Date': date,
        'Time': time,
        'Status': 'Pending',
        'CreatedAt': FieldValue.serverTimestamp(),
        'IsTestData': false,
        'userId': userId,
      };
      
      debugPrint("Adding booking with data: $bookingData");
      
      await _firestore.collection('Booking').add(bookingData);
      
      debugPrint('Booking added to Booking collection with proper fields and custom date/time');
      
      Get.snackbar(
        'Success',
        'Booking added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error adding booking: $e');
      Get.snackbar(
        'Error',
        'Failed to add booking: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
