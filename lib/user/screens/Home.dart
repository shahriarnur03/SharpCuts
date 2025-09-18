import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sharpcuts/constants/app_colors.dart';
import 'package:sharpcuts/routes/app_routes.dart';
import 'package:sharpcuts/user/widgets/services_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with greeting and avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello",
                          style: TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Guest",
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.offAllNamed(AppRoutes.login);
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/profile.png'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 20),

                const Text(
                  "Services",
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Services grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: const [
                      ServicesCard(
                        imagePath: "assets/images/shaving.png",
                        title: "Classical Shaving",
                      ),
                      ServicesCard(
                        imagePath: "assets/images/hair.png",
                        title: "Hair Washing",
                      ),
                      ServicesCard(
                        imagePath: "assets/images/cutting.png",
                        title: "Hair Cutting",
                      ),
                      ServicesCard(
                        imagePath: "assets/images/beard.png",
                        title: "Beard Trimming",
                      ),
                      ServicesCard(
                        imagePath: "assets/images/facials.png",
                        title: "Facials",
                      ),
                      ServicesCard(
                        imagePath: "assets/images/kids.png",
                        title: "Kids Hair Cutting",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

