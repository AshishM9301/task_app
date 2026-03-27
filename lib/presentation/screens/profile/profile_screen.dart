import 'package:flutter/material.dart';
import 'package:task_app/core/constants/app_constants.dart';
import 'package:task_app/core/widgets/icons/icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 160.0,
                      height: 160.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppConstants.primaryColor,
                          width: 6,
                        ),
                      ),
                      child: Container(
                        width: 190.0,
                        height: 190.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                              "https://i.imgur.com/BoN9kdC.png",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "John Doe",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "john.doe@example.com",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(context, "Total Completed", "24"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(context, "Active", "5")),
                ],
              ),
              const SizedBox(height: 30),
              _buildMenuItem(context, "Account Settings", Icons.person),
              _buildMenuItem(context, "Preferences", Icons.settings),
              _buildMenuItem(context, "Privacy", Icons.privacy_tip),
              _buildMenuItem(context, "Logout", Icons.logout, isLogout: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Card(
      color: AppConstants.whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            Text(
              value.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isLogout = false,
  }) {
    return Card(
      color: isLogout ? Colors.red[100] : AppConstants.whiteColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isLogout ? Colors.red : AppConstants.primaryColor,
            ),
          ),
          title: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isLogout ? Colors.red : AppConstants.primaryColor,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isLogout ? Colors.red : Colors.grey[400],
          ),
          onTap: () {
            // Handle tap
          },
        ),
      ),
    );
  }
}
