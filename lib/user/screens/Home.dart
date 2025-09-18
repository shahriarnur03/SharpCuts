import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharpcuts/constants/app_colors.dart';
import 'package:sharpcuts/user/services/database.dart';
import 'package:sharpcuts/user/services/user_auth_service.dart';
import 'package:sharpcuts/user/widgets/services_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _userNameFuture = _getUserName();
  }

  Future<String> _getUserName() async {
    // Get current user
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return "Guest";
    }
    
    // Try to get user from Firestore first
    try {
      final userData = await _databaseMethods.getUserDetailsById(currentUser.uid);
      if (userData != null && userData.containsKey("Name") && userData["Name"] != null) {
        return userData["Name"];
      }
    } catch (e) {
      print("Error fetching user data from Firestore: $e");
    }
    
    // If Firestore fails, try Firebase Auth display name
    if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
      return currentUser.displayName!;
    }
    
    // Fall back to email if no name is found
    if (currentUser.email != null && currentUser.email!.isNotEmpty) {
      // Return the part before @ in email
      return currentUser.email!.split('@')[0];
    }
    
    // Last resort
    return "Guest";
  }

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
                    FutureBuilder<String>(
                      future: _userNameFuture,
                      builder: (context, snapshot) {
                        String userName = "Guest";
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                          userName = snapshot.data!;
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Hello",
                              style: TextStyle(
                                color: AppColors.lightTextColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              userName,
                              style: const TextStyle(
                                color: AppColors.textColor,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    PopupMenuButton(
                      icon: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: const AssetImage('assets/images/profile.png'),
                        ),
                      ),
                      color: AppColors.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: AppColors.textColor,
                            ),
                            title: const Text(
                              "Profile",
                              style: TextStyle(
                                color: AppColors.textColor,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Add profile navigation if needed
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: AppColors.textColor,
                            ),
                            title: const Text(
                              "Logout",
                              style: TextStyle(
                                color: AppColors.textColor,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              UserAuthService.logoutUser(context);
                            },
                          ),
                        ),
                      ],
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

