import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBooking(String serviceName, String userId) async {
    try {
      await _firestore.collection('bookings').add({
        'serviceName': serviceName,
        'userId': userId,
        'timestamp': Timestamp.now(),
      });
      Get.snackbar(
        'Success',
        'Booking added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add booking: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
