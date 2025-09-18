import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
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
      return null;
    }
  }
  Future addUserBooking(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Booking")
        .add(userInfoMap);
  }

  Stream<QuerySnapshot> getBookings() {
    debugPrint("Fetching bookings from Firestore...");
    try {
      // Check if collection exists first
      FirebaseFirestore.instance.collection("Booking").get().then((value) {
        debugPrint("Booking collection exists with ${value.docs.length} documents");
      }).catchError((error) {
        debugPrint("Error checking Booking collection: $error");
      });
      
      // Set up the stream with order by date (newest first)
      final stream = FirebaseFirestore.instance
          .collection("Booking")
          .orderBy("Date", descending: true)
          .snapshots();
      
      // Add a listener to check if data is coming through
      stream.listen(
        (QuerySnapshot snapshot) {
          debugPrint("Received booking data: ${snapshot.docs.length} documents");
          if (snapshot.docs.isNotEmpty) {
            debugPrint("First booking: ${snapshot.docs.first.data()}");
          } else {
            debugPrint("No booking documents found in the snapshot");
          }
        },
        onError: (error) {
          debugPrint("Error listening to bookings: $error");
          debugPrint("Error details: ${error.toString()}");
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
    return await FirebaseFirestore.instance
        .collection("Booking")
        .doc(bookingId)
        .update({"Status": "Accepted"});
  }

  Future<void> deleteBooking(String bookingId) async {
    return await FirebaseFirestore.instance
        .collection("Booking")
        .doc(bookingId)
        .delete();
  }
}
