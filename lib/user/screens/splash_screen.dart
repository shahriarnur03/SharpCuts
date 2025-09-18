import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sharpcuts/constants/app_colors.dart';
import 'package:sharpcuts/routes/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Delayed navigation to the home screen
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.login);
    });

    return Scaffold(
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
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              // App title
              Text(
                'SharpCuts',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                'Premium Cut & Shave',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.lightTextColor,
                      fontWeight: FontWeight.w400,
                    ),
              ),

              const SizedBox(height: 60),

              // Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.adminLogin);
                },
                child: const Text(
                  'Admin Login',
                  style: TextStyle(color: AppColors.lightTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
