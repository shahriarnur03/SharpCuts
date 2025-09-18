import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sharpcuts/routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;

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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
