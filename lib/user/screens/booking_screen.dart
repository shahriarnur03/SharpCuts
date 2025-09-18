import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sharpcuts/constants/app_colors.dart';
import 'package:sharpcuts/user/controllers/booking_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatelessWidget {
  final String service;

  const BookingScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final BookingController _bookingController = Get.put(BookingController());
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Now'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.accentColor,
              AppColors.secondaryColor,
              AppColors.primaryColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You are booking:',
                style: TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                service,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (userId != null) {
                    _bookingController.addBooking(service, userId);
                  } else {
                    Get.snackbar(
                      'Error',
                      'User not logged in.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
