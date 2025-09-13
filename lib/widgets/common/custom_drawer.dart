import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, authProvider),
          
          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
          ),
          
          // Courses
          ExpansionTile(
            leading: const Icon(Icons.book),
            title: const Text('Courses'),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('All Courses'),
                contentPadding: const EdgeInsets.only(left: 32.0),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to courses screen
                },
              ),
              if (authProvider.isAdmin || authProvider.isFaculty)
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Course'),
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to add course screen
                  },
                ),
            ],
          ),
          
          // Subjects
          ExpansionTile(
            leading: const Icon(Icons.subject),
            title: const Text('Subjects'),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('All Subjects'),
                contentPadding: const EdgeInsets.only(left: 32.0),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to subjects screen
                },
              ),
              if (authProvider.isAdmin || authProvider.isFaculty)
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Subject'),
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to add subject screen
                  },
                ),
            ],
          ),
          
          // Documents
          ListTile(
            leading: const Icon(Icons.file_copy),
            title: const Text('Documents'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to documents screen
            },
          ),
          
          // Notices
          ExpansionTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Notices'),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('All Notices'),
                contentPadding: const EdgeInsets.only(left: 32.0),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to notices screen
                },
              ),
              if (authProvider.isAdmin || authProvider.isFaculty)
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Notice'),
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to add notice screen
                  },
                ),
            ],
          ),
          
          // Admin Panel (only for admin)
          if (authProvider.isAdmin)
            ExpansionTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Panel'),
              children: [
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Manage Users'),
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to manage users screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('System Settings'),
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to system settings screen
                  },
                ),
              ],
            ),
          
          const Divider(),
          
          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile screen
            },
          ),
          
          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _showLogoutConfirmationDialog(context, authProvider);
            },
          ),
          
          // App version
          ListTile(
            title: Text(
              'Version ${AppConfig.appVersion}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            onTap: null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerHeader(BuildContext context, AuthProvider authProvider) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              _getInitials(authProvider.name ?? 'User'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // User name
          Text(
            authProvider.name ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // User email
          Text(
            authProvider.email ?? 'user@example.com',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          
          // User role and department
          Text(
            '${_capitalizeFirstLetter(authProvider.role ?? 'User')} - ${authProvider.department ?? 'N/A'}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutConfirmationDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              Navigator.pop(context); // Close dialog
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    String initials = '';
    
    if (nameParts.isNotEmpty) {
      initials += nameParts[0][0];
      
      if (nameParts.length > 1) {
        initials += nameParts[nameParts.length - 1][0];
      }
    }
    
    return initials.toUpperCase();
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}