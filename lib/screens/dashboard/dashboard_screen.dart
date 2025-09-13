import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_drawer.dart';
import '../courses/courses_screen.dart';
import '../notices/notices_screen.dart';
import '../profile/profile_screen.dart';
// ✅ make sure this file defines `class ProfileScreen extends StatefulWidget`

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];
  final List<String> _titles = [
    'Dashboard',
    'Courses',
    'Notices',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize screens
    _screens.addAll([
      _buildDashboardContent(),
      const CoursesScreen(),
      const NoticesScreen(),
      const ProfileScreen(), // ✅ This must match your profile_screen.dart class
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          // Theme toggle button
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
            },
          ),

          // Notifications button
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Notices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Card(
                elevation: AppTheme.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authProvider.name ?? 'User'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Role: ${_capitalizeFirstLetter(authProvider.role ?? 'User')}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Department: ${authProvider.department ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Quick actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildQuickActions(authProvider),

              const SizedBox(height: 20),

              // Recent notices
              const Text(
                'Recent Notices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildRecentNotices(),

              const SizedBox(height: 20),

              // Recent courses
              const Text(
                'Your Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildRecentCourses(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(AuthProvider authProvider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildActionCard(
          icon: Icons.book,
          title: 'View Courses',
          onTap: () {
            setState(() {
              _currentIndex = 1;
            });
          },
        ),
        _buildActionCard(
          icon: Icons.announcement,
          title: 'View Notices',
          onTap: () {
            setState(() {
              _currentIndex = 2;
            });
          },
        ),
        if (authProvider.isAdmin || authProvider.isFaculty)
          _buildActionCard(
            icon: Icons.add_circle,
            title: 'Add Content',
            onTap: () {
              // Navigate to content creation screen
            },
          ),
        _buildActionCard(
          icon: Icons.person,
          title: 'Profile',
          onTap: () {
            setState(() {
              _currentIndex = 3;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentNotices() {
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Card(
              elevation: AppTheme.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.announcement, color: Colors.white),
                ),
                title: Text('Notice ${index + 1}'),
                subtitle: Text('This is a sample notice ${index + 1}'),
                trailing: const Text('Today'),
                onTap: () {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentCourses() {
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Card(
              elevation: AppTheme.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor,
                  child: Icon(Icons.book, color: Colors.white),
                ),
                title: Text('Course ${index + 1}'),
                subtitle: Text('This is a sample course ${index + 1}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            );
          },
        );
      },
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
