import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharpcuts/admin/services/database.dart';
import 'package:sharpcuts/constants/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  static const String name = '/admin-dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Stream? bookingStream;

  @override
  void initState() {
    super.initState();
    bookingStream = DatabaseMethods().getBookings();
  }

  Widget allBookings() {
    return StreamBuilder(
      stream: bookingStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Some error occurred"));
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(child: Text("No bookings found."));
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return Card(
              color: AppColors.cardColor,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: ds['Image'] != null && ds['Image'] is String
                              ? NetworkImage(ds['Image'])
                              : const AssetImage('assets/images/profile.png') as ImageProvider,
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Service: ${ds['Service'] ?? 'N/A'}",
                              style: const TextStyle(color: AppColors.textColor, fontSize: 16),
                            ),
                            Text(
                              "Name: ${ds['Name'] ?? 'N/A'}",
                              style: const TextStyle(color: AppColors.textColor, fontSize: 16),
                            ),
                            Text(
                              "Date: ${ds['Date'] ?? 'N/A'}",
                              style: const TextStyle(color: AppColors.textColor, fontSize: 16),
                            ),
                            Text(
                              "Time: ${ds['Time'] ?? 'N/A'}",
                              style: const TextStyle(color: AppColors.textColor, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await DatabaseMethods().acceptBooking(ds.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("Booking Accepted"),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Accept"),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () async {
                            await DatabaseMethods().deleteBooking(ds.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Booking Rejected"),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentColor,
              AppColors.secondaryColor,
              AppColors.primaryColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "All Bookings",
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(child: allBookings()),
            ],
          ),
        ),
      ),
    );
  }
}
