import 'package:get/get.dart';
import 'package:sharpcuts/admin/add_service.dart';
import 'package:sharpcuts/admin/admin_login.dart';
import 'package:sharpcuts/admin/screens/admin_dashboard_screen.dart';
import 'package:sharpcuts/admin/screens/admin_login_screen.dart';
import 'package:sharpcuts/admin/screens/admin_setup_screen.dart';
import 'package:sharpcuts/user/screens/Home.dart';
import 'package:sharpcuts/user/screens/booking_screen.dart';
import 'package:sharpcuts/user/screens/login_screen.dart';
import 'package:sharpcuts/user/screens/signup_screen.dart';
import 'package:sharpcuts/user/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String booking = '/booking';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String adminLogin = '/adminLogin';
  static const String adminDashboard = '/adminDashboard';
  static const String addService = '/addService';
  static const String adminSetup = '/adminSetup';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: booking, page: () => BookingScreen(service: Get.arguments)),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: adminLogin, page: () => const AdminLoginScreen()),
    GetPage(name: adminDashboard, page: () => const AdminDashboardScreen()),
    GetPage(name: addService, page: () => const AddServiceScreen()),
    GetPage(name: adminSetup, page: () => const AdminSetupScreen()),
  ];
}
