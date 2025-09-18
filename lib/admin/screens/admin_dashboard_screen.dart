import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sharpcuts/admin/services/admin_auth_service.dart';
import 'package:sharpcuts/admin/services/database.dart';
import 'package:sharpcuts/admin/utils/firebase_access_checker.dart';
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
    
    // Initialize booking stream
    bookingStream = DatabaseMethods().getBookings();
    
    // Check if Firestore has any bookings, if not add a test booking
    _checkAndAddTestBookingIfNeeded();
    
    // Verify admin collection
    FirebaseAccessChecker.verifyAdminCollection();
    
    // Check Firebase access
    FirebaseAccessChecker.checkBookingsAccess().then((hasAccess) {
      debugPrint("Admin has access to Booking collection: $hasAccess");
      if (!hasAccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Warning: Limited access to Firebase. Some features may not work."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }
  
  Future<void> _checkAndAddTestBookingIfNeeded() async {
    try {
      // Get booking collection reference
      final bookingsRef = FirebaseFirestore.instance.collection("Booking");
      
      // Check if there are any bookings
      final snapshot = await bookingsRef.get();
      
      debugPrint("Found ${snapshot.docs.length} bookings in the collection");
      
      // If no bookings exist, add a test booking
      if (snapshot.docs.isEmpty) {
        debugPrint("No bookings found, adding test booking");
        
        final testBookingData = {
          'Name': 'Test Customer',
          'Service': 'Haircut',
          'Date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          'Time': '10:00 AM',
          'Status': 'Pending',
          'Email': 'test@example.com',
          'Phone': '1234567890',
          // Adding createdAt timestamp
          'CreatedAt': FieldValue.serverTimestamp(),
          'IsTestData': true,
        };
        
        await bookingsRef.add(testBookingData);
        debugPrint("Test booking added successfully with data: $testBookingData");
        
        // Refresh the stream
        setState(() {
          bookingStream = DatabaseMethods().getBookings();
        });
      } else {
        debugPrint("Bookings already exist: ${snapshot.docs.length}");
        
        // Check if any existing booking is a test booking
        bool hasTestBooking = false;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data['IsTestData'] == true) {
            hasTestBooking = true;
            break;
          }
        }
        
        // If we don't have a test booking, add one for demonstration
        if (!hasTestBooking) {
          debugPrint("No test bookings found, adding one for demonstration");
          await bookingsRef.add({
            'Name': 'Demo Booking',
            'Service': 'Beard Trim',
            'Date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            'Time': '2:00 PM',
            'Status': 'Pending',
            'Email': 'demo@example.com',
            'Phone': '9876543210',
            'CreatedAt': FieldValue.serverTimestamp(),
            'IsTestData': true,
          });
          
          // Refresh the stream
          setState(() {
            bookingStream = DatabaseMethods().getBookings();
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking/adding test booking: $e");
    }
  }

  Widget allBookings() {
    return StreamBuilder(
      stream: bookingStream,
      builder: (context, AsyncSnapshot snapshot) {
        debugPrint("StreamBuilder state: ${snapshot.connectionState}");
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading bookings...", style: TextStyle(color: AppColors.textColor)),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          debugPrint("StreamBuilder error: ${snapshot.error}");
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text("Error loading bookings", style: TextStyle(color: AppColors.textColor, fontSize: 18)),
                SizedBox(height: 8),
                Text("${snapshot.error}", style: TextStyle(color: Colors.red[300])),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text("Retry"),
                  onPressed: () {
                    setState(() {
                      bookingStream = DatabaseMethods().getBookings();
                    });
                  },
                ),
              ],
            ),
          );
        }
        
        if (!snapshot.hasData) {
          debugPrint("StreamBuilder: No data available");
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: AppColors.textColor),
                SizedBox(height: 16),
                Text("No booking data available", style: TextStyle(color: AppColors.textColor, fontSize: 18)),
              ],
            ),
          );
        }
        
        if (snapshot.data.docs.isEmpty) {
          debugPrint("StreamBuilder: Empty docs list");
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.textColor),
                SizedBox(height: 16),
                Text("No bookings found", style: TextStyle(color: AppColors.textColor, fontSize: 18)),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checkAndAddTestBookingIfNeeded,
                  child: const Text("Add Test Booking"),
                ),
              ],
            ),
          );
        }
        
        debugPrint("StreamBuilder: Rendering ${snapshot.data.docs.length} bookings");
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
                          backgroundColor: AppColors.accentColor,
                          backgroundImage: const AssetImage('assets/images/profile.png'),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Service: ${ds['Service'] ?? 'N/A'}",
                                style: const TextStyle(color: AppColors.textColor, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Name: ${ds['Name'] ?? 'N/A'}",
                                style: const TextStyle(color: AppColors.textColor, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Date: ${ds['Date'] ?? 'N/A'}",
                                style: const TextStyle(color: AppColors.textColor, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Time: ${ds['Time'] ?? 'N/A'}",
                                style: const TextStyle(color: AppColors.textColor, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ds['Status'] == 'Accepted' 
                                ? Colors.green.withOpacity(0.2)
                                : ds['Status'] == 'Pending' 
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ds['Status'] == 'Accepted' 
                                  ? Colors.green
                                  : ds['Status'] == 'Pending' 
                                      ? Colors.orange
                                      : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            ds['Status'] ?? 'Unknown',
                            style: TextStyle(
                              color: ds['Status'] == 'Accepted' 
                                  ? Colors.green
                                  : ds['Status'] == 'Pending' 
                                      ? Colors.orange
                                      : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
        actions: [
          // Check Firebase button
          IconButton(
            icon: const Icon(Icons.health_and_safety_outlined),
            tooltip: "Check Firebase Access",
            onPressed: () {
              FirebaseAccessChecker.showAccessStatusDialog(context);
            },
          ),
          // Logout button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              onPressed: () {
                AdminAuthService.logoutAdmin(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.white54, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
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
              const SizedBox(height: 4.0),
              // Refresh button
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Refresh Bookings"),
                onPressed: () {
                  setState(() {
                    bookingStream = DatabaseMethods().getBookings();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Refreshing bookings..."),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: AppColors.textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
