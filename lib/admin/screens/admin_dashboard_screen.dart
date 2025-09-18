import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    
    // Check if Firestore has any bookings
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
      
      // Just check if any bookings exist without filtering
      if (snapshot.docs.isEmpty) {
        debugPrint("No bookings found. Booking data should be added through user app.");
      } else {
        debugPrint("Bookings exist: ${snapshot.docs.length}");
      }
    } catch (e) {
      debugPrint("Error checking bookings: $e");
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
                SizedBox(height: 8),
                Text(
                  "When customers make bookings through the app, they will appear here", 
                  style: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text("Refresh"),
                  onPressed: () {
                    setState(() {
                      bookingStream = DatabaseMethods().getBookings();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textColor,
                  ),
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
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3), width: 1),
              ),
              color: AppColors.accentColor.withOpacity(0.8),
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.accentColor,
                      AppColors.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service title header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${ds['Service'] ?? 'Booking Service'}",
                          style: const TextStyle(
                            color: AppColors.textColor, 
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Customer details
                      Row(
                        children: [
                          // Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.7),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.secondaryColor,
                              backgroundImage: const AssetImage('assets/images/profile.png'),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // Customer info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Customer name
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: AppColors.lightTextColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${ds['Name'] ?? 'N/A'}",
                                        style: const TextStyle(
                                          color: AppColors.textColor, 
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Email if available
                                if (ds['Email'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.email, size: 16, color: AppColors.lightTextColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "${ds['Email']}",
                                          style: const TextStyle(
                                            color: AppColors.lightTextColor, 
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (ds['Email'] != null)
                                  const SizedBox(height: 6),
                                // Date
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: AppColors.lightTextColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${ds['Date'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        color: AppColors.lightTextColor, 
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Time
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: AppColors.lightTextColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${ds['Time'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        color: AppColors.lightTextColor, 
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Phone
                                if (ds['Phone'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 16, color: AppColors.lightTextColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${ds['Phone']}",
                                        style: const TextStyle(
                                          color: AppColors.lightTextColor, 
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      // Divider
                      Divider(color: AppColors.primaryColor.withOpacity(0.3), thickness: 1),
                      const SizedBox(height: 8.0),
                      // Status and actions row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ds['Status'] == 'Accepted' 
                                  ? Colors.green.withOpacity(0.2)
                                  : ds['Status'] == 'Pending' 
                                      ? Colors.orange.withOpacity(0.2)
                                      : ds['Status'] == 'Rejected'
                                          ? Colors.red.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ds['Status'] == 'Accepted' 
                                    ? Colors.green
                                    : ds['Status'] == 'Pending' 
                                        ? Colors.orange
                                        : ds['Status'] == 'Rejected'
                                            ? Colors.red
                                            : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  ds['Status'] == 'Accepted' 
                                      ? Icons.check_circle
                                      : ds['Status'] == 'Pending' 
                                          ? Icons.pending
                                          : ds['Status'] == 'Rejected'
                                              ? Icons.cancel
                                              : Icons.info,
                                  size: 16,
                                  color: ds['Status'] == 'Accepted' 
                                      ? Colors.green
                                      : ds['Status'] == 'Pending' 
                                          ? Colors.orange
                                          : ds['Status'] == 'Rejected'
                                              ? Colors.red
                                              : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ds['Status'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: ds['Status'] == 'Accepted' 
                                        ? Colors.green
                                        : ds['Status'] == 'Pending' 
                                            ? Colors.orange
                                            : ds['Status'] == 'Rejected'
                                                ? Colors.red
                                                : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Only show Accept button if status is not already Accepted
                              if (ds['Status'] != 'Accepted')
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text("Accept"),
                                  onPressed: () async {
                                    await DatabaseMethods().acceptBooking(ds.id);
                                    
                                    // Refresh the booking stream to update UI
                                    if (mounted) {
                                      setState(() {
                                        bookingStream = DatabaseMethods().getBookings();
                                      });
                                    }
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text("Booking Accepted"),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              // Add spacing only if both buttons are shown
                              if (ds['Status'] != 'Accepted')
                                const SizedBox(width: 8.0),
                              // Always show the Reject/Delete button
                              ElevatedButton.icon(
                                icon: const Icon(Icons.close, size: 16),
                                label: Text(ds['Status'] == 'Accepted' ? "Cancel" : "Reject"),
                                onPressed: () async {
                                  // Instead of deleting, change status to Rejected
                                  await DatabaseMethods().rejectBooking(ds.id);
                                  
                                  // Refresh the booking stream to update UI
                                  if (mounted) {
                                    setState(() {
                                      bookingStream = DatabaseMethods().getBookings();
                                    });
                                  }
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(ds['Status'] == 'Accepted' ? "Booking Cancelled" : "Booking Rejected"),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
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
        title: const Text(
          'Admin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.textColor,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          // Logout icon that uses the existing AdminAuthService logout method
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColors.textColor,
              size: 24,
            ),
            onPressed: () {
              // Use the existing logout method which already has a confirmation dialog
              AdminAuthService.logoutAdmin(context);
            },
            tooltip: 'Logout',
            splashRadius: 24,
          ),
          const SizedBox(width: 8),
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
              // Dashboard header
              
              const SizedBox(height: 16.0),
              Expanded(child: allBookings()),
            ],
          ),
        ),
      ),
    );
  }
}
