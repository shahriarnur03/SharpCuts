import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A utility class for checking and verifying Firebase access and permissions
class FirebaseAccessChecker {
  /// Checks if the current user has read access to the Booking collection
  static Future<bool> checkBookingsAccess() async {
    try {
      debugPrint("Checking access to Booking collection...");
      
      // Check if user is signed in
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint("No user is signed in");
        return false;
      }
      
      debugPrint("Signed in user: ${currentUser.email}");
      
      // Try to access the Booking collection
      await FirebaseFirestore.instance
          .collection("Booking")
          .limit(1)
          .get();
      
      debugPrint("Successfully accessed Booking collection");
      return true;
    } catch (e) {
      debugPrint("Error accessing Booking collection: $e");
      return false;
    }
  }

  /// Checks Firestore connectivity and debugging status
  static Future<Map<String, dynamic>> checkFirestoreConnection() async {
    try {
      debugPrint("Checking Firestore connection...");
      
      // Try to access the Booking collection
      final snapshot = await FirebaseFirestore.instance
          .collection("Booking")
          .get();
      
      // Count total bookings and test bookings
      int testBookings = 0;
      int realBookings = 0;
      
      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('IsTestData') && doc['IsTestData'] == true) {
          testBookings++;
        } else {
          realBookings++;
        }
      }
      
      // Get Firebase project ID
      String projectId = FirebaseFirestore.instance.app.options.projectId;
      
      return {
        'connected': true,
        'totalBookings': snapshot.docs.length,
        'realBookings': realBookings,
        'testBookings': testBookings,
        'projectId': projectId,
      };
    } catch (e) {
      debugPrint("Error checking Firestore connection: $e");
      return {
        'connected': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Creates a test booking document to verify write access
  static Future<bool> createTestBooking() async {
    try {
      debugPrint("Creating test booking...");
      
      // Create a test booking
      final docRef = await FirebaseFirestore.instance.collection("Booking").add({
        'Name': 'Test Customer',
        'Service': 'Test Service',
        'Date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        'Time': '12:00 PM',
        'Status': 'Test',
        'Email': 'test@example.com',
        'Phone': '0000000000',
        'CreatedAt': FieldValue.serverTimestamp(),
        'IsTestData': true,
      });
      
      debugPrint("Test booking created with ID: ${docRef.id}");
      return true;
    } catch (e) {
      debugPrint("Error creating test booking: $e");
      return false;
    }
  }
  
  /// Checks if the "Admin" collection exists and verifies admin account
  static Future<void> verifyAdminCollection() async {
    try {
      final adminEmail = "admin@gmail.com";
      
      // Check if Admin collection exists
      final adminCollection = FirebaseFirestore.instance.collection("Admin");
      final adminSnapshot = await adminCollection.where("Email", isEqualTo: adminEmail).get();
      
      if (adminSnapshot.docs.isEmpty) {
        debugPrint("Admin account not found in Admin collection. Creating...");
        
        // Create admin document
        await adminCollection.add({
          "Email": adminEmail,
          "Password": "123456", // This is unsafe - in a real app use hashed passwords
          "Role": "admin",
          "CreatedAt": FieldValue.serverTimestamp(),
        });
        
        debugPrint("Admin account created successfully");
      } else {
        debugPrint("Admin account exists in Admin collection");
      }
    } catch (e) {
      debugPrint("Error verifying admin collection: $e");
    }
  }
  
  /// Displays a dialog showing Firebase access status
  static Future<void> showAccessStatusDialog(BuildContext context) async {
    bool bookingsAccess = await checkBookingsAccess();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Firebase Access Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User: ${FirebaseAuth.instance.currentUser?.email ?? 'Not signed in'}"),
            SizedBox(height: 8),
            Row(
              children: [
                Text("Bookings Collection Access: "),
                bookingsAccess 
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.cancel, color: Colors.red),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close"),
          ),
          if (!bookingsAccess)
            TextButton(
              onPressed: () async {
                await createTestBooking();
                Navigator.pop(context);
              },
              child: Text("Create Test Booking"),
            ),
        ],
      ),
    );
  }
}