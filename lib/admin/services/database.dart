import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
  // Safe access to field values with default fallbacks
  static dynamic safeGet(Map<String, dynamic>? data, String field, dynamic defaultValue) {
    if (data == null) return defaultValue;
    return data.containsKey(field) ? data[field] : defaultValue;
  }
  
  // Convert Firestore document to a standardized booking object
  static Map<String, dynamic> normalizeBookingData(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Create a standardized booking object with consistent field names
    return {
      'id': doc.id,
      'CustomerName': safeGet(data, 'Name', data['Email'] != null ? data['Email'].toString().split('@')[0] : 'Customer'),
      'CustomerEmail': safeGet(data, 'Email', null),
      'CustomerPhone': safeGet(data, 'Phone', null),
      'Service': safeGet(data, 'Service', 'Unknown'),
      'Date': safeGet(data, 'Date', 'No date'),
      'Time': safeGet(data, 'Time', 'No time'),
      'Status': safeGet(data, 'Status', 'Pending'),
      'CreatedAt': safeGet(data, 'CreatedAt', null),
      'Image': safeGet(data, 'Image', null),
      'IsTestData': safeGet(data, 'IsTestData', false),
      'Notes': safeGet(data, 'Notes', null),
      // Keep the original data for reference
      'rawData': data,
    };
  }

  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future<Map<String, dynamic>?> getUserDetailsByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("Email", isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return userData;
      }
      return null;
    } catch (e) {
      debugPrint("Error getting user details: $e");
      return null;
    }
  }
  
  Future addUserBooking(Map<String, dynamic> userInfoMap) async {
    try {
      // Ensure we have all required fields for admin dashboard
      if (!userInfoMap.containsKey('CreatedAt')) {
        userInfoMap['CreatedAt'] = FieldValue.serverTimestamp();
      }
      
      // Standardize field names - add required fields if missing
      if (!userInfoMap.containsKey('Name') && userInfoMap.containsKey('CustomerName')) {
        userInfoMap['Name'] = userInfoMap['CustomerName'];
      }
      
      if (!userInfoMap.containsKey('Email') && userInfoMap.containsKey('CustomerEmail')) {
        userInfoMap['Email'] = userInfoMap['CustomerEmail'];
      }
      
      if (!userInfoMap.containsKey('Status')) {
        userInfoMap['Status'] = 'Pending';
      }
      
      if (!userInfoMap.containsKey('IsTestData')) {
        userInfoMap['IsTestData'] = false;
      }
      
      // Use a consistent collection name - "Booking" singular
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection("Booking")
          .add(userInfoMap);
      
      debugPrint("Added booking with ID: ${docRef.id}");
      return docRef;
    } catch (e) {
      debugPrint("Error adding booking: $e");
      rethrow; // Rethrow to allow caller to handle the error
    }
  }

  Stream<QuerySnapshot> getBookings() {
    debugPrint("Fetching bookings from Firestore...");
    try {
      // Simplified query that doesn't require a composite index
      // Just get all bookings and sort by creation date
      final stream = FirebaseFirestore.instance
          .collection("Booking")  // Consistent naming - singular "Booking"
          .orderBy("CreatedAt", descending: true)
          .snapshots();
      
      // Add a listener to check if data is coming through
      stream.listen(
        (QuerySnapshot snapshot) {
          debugPrint("Received booking data: ${snapshot.docs.length} documents");
          if (snapshot.docs.isNotEmpty) {
            debugPrint("Successfully retrieved bookings");
            
            if (snapshot.docs.isNotEmpty) {
              var firstDoc = snapshot.docs.first.data() as Map<String, dynamic>;
              debugPrint("Sample booking fields: ${firstDoc.keys.join(', ')}");
            }
          } else {
            debugPrint("No booking documents found in the snapshot");
          }
        },
        onError: (error) {
          debugPrint("Error listening to bookings: $error");
          if (error is FirebaseException) {
            debugPrint("Firebase error code: ${error.code}");
            debugPrint("Firebase error message: ${error.message}");
          }
        },
        cancelOnError: false,
      );
      
      return stream;
    } catch (e) {
      debugPrint("Error getting bookings stream: $e");
      debugPrint("Stack trace: ${StackTrace.current}");
      // Return an empty stream as fallback
      return Stream.empty();
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Booking")
          .doc(bookingId)
          .update({
            "Status": "Accepted", 
            "UpdatedAt": FieldValue.serverTimestamp()
          });
      debugPrint("Booking $bookingId accepted successfully");
    } catch (e) {
      debugPrint("Error accepting booking: $e");
      rethrow;
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Booking")
          .doc(bookingId)
          .update({
            "Status": "Rejected", 
            "UpdatedAt": FieldValue.serverTimestamp()
          });
      debugPrint("Booking $bookingId rejected successfully");
    } catch (e) {
      debugPrint("Error rejecting booking: $e");
      rethrow;
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Booking")
          .doc(bookingId)
          .delete();
      debugPrint("Booking $bookingId deleted successfully");
    } catch (e) {
      debugPrint("Error deleting booking: $e");
      rethrow;
    }
  }
}
