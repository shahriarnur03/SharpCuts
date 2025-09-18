import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sharpcuts/routes/app_routes.dart';
import 'package:sharpcuts/user/services/database.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(FirebaseAuth.instance.currentUser);
    print("onReady: Initial user value: ${_user.value?.email}");
    
    // Only monitor sign out events to redirect to login
    _user.bindStream(FirebaseAuth.instance.authStateChanges());
    ever(_user, _checkSignOut);
  }

  // Only check for sign out events, not auto-login
  _checkSignOut(User? user) {
    print("Auth state changed. User: ${user?.email}");
    
    // If user signed out, redirect to login
    if (user == null && Get.currentRoute != AppRoutes.login && Get.currentRoute != AppRoutes.splash) {
      print("User signed out, redirecting to login");
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void signUp(String name, String email, String password) async {
    try {
      // Create the user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // If successful, save user details to Firestore
      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        
        // Set display name for the Firebase Auth user
        await userCredential.user!.updateDisplayName(name);
        
        // Create user data map with standard field names
        Map<String, dynamic> userMap = {
          "Name": name,
          "Email": email,
          "Phone": "", // Default empty value for phone
          "CreatedAt": DateTime.now().millisecondsSinceEpoch,
          "LastUpdated": DateTime.now().millisecondsSinceEpoch,
        };
        
        // Save user details to Firestore
        await _databaseMethods.addUserDetails(userMap, userId);
        
        print("User details saved to Firestore for user: $email");
      }
      
      // Navigate to home screen
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void login(String email, String password) async {
    try {
      print("Attempting to log in with email: $email");
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Login successful for email: $email");
      
      // Explicitly navigate to home after successful login
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      print("Login failed for email: $email with error: ${e.toString()}");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
