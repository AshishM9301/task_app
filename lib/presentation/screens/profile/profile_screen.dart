import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/utils/api_service.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../friends/friends_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  int _totalCompleted = 0;
  int _activeTasks = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
    });
  }

  Future<void> _fetchProfile() async {
    final guestProvider = context.read<GuestProvider>();
    if (!guestProvider.hasGuestKey) {
      await guestProvider.initializeGuestKey();
    }
    _apiService.setGuestKey(guestProvider.guestKey ?? '');

    setState(() {
      _isLoading = true;
    });

    try {
      final userResponse = await _apiService.getMe();
      final dashboardResponse = await _apiService.getDashboard();

      setState(() {
        if (userResponse.success && userResponse.data != null) {
          _userData = userResponse.data;
        }
        if (dashboardResponse.success && dashboardResponse.data != null) {
          final overview = dashboardResponse.data!['overview'] ?? {};
          _totalCompleted = overview['completedTasks'] ?? 0;
          _activeTasks = overview['inProgressTasks'] ?? 0;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return LoginScreen(
            onLoginSuccess: () {
              setState(() {
                _isLoading = true;
              });
              _fetchProfile();
            },
          );
        }

        return Scaffold(
          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchProfile,
              color: AppConstants.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileHeader(authProvider.user),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Total Completed', '$_totalCompleted'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard('Active', '$_activeTasks'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildMenuItem('Friends', Icons.people, _handleFriends),
                    _buildMenuItem('Account Settings', Icons.person, () {}),
                    _buildMenuItem('Preferences', Icons.settings, () {}),
                    _buildMenuItem('Privacy', Icons.privacy_tip, () {}),
                    _buildMenuItem('Logout', Icons.logout, _handleLogout, isLogout: true),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(user) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }

    final photoUrl = user?.photoURL ?? _userData?['photo_url'];
    final displayName = user?.displayName ?? _userData?['display_name'] ?? 'User';
    final email = user?.email ?? _userData?['email'] ?? '';

    return Center(
      child: Column(
        children: [
          Stack(
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
                      image: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : const NetworkImage('https://i.imgur.com/BoN9kdC.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
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
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
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
    String title,
    IconData icon,
    VoidCallback onTap, {
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
          onTap: onTap,
        ),
      ),
    );
  }

  void _handleFriends() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FriendsScreen()),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              final guestProvider = context.read<GuestProvider>();
              authProvider.signOut();
              guestProvider.clearGuestKey();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}