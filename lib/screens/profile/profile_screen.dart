import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  File? _profileImage;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _nameController.text = authProvider.name ?? '';
    _emailController.text = authProvider.email ?? '';
    
    // Fetch additional user data
    _fetchUserProfile();
  }
  
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final userData = await ApiService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _contactNumberController.text = userData['data']['contactNumber'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Update profile data
      final data = {
        'name': _nameController.text,
        'contactNumber': _contactNumberController.text,
      };
      
      await ApiService.updateProfile(data);
      
      // Update profile picture if selected
      if (_profileImage != null) {
        // Create a method to handle profile picture upload
        await _uploadProfilePicture(_profileImage!);
      }
      
      // Update auth provider
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateProfile(data);
        
        setState(() {
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Custom method to handle profile picture upload
  Future<void> _uploadProfilePicture(File imageFile) async {
    try {
      // You can implement this method in your ApiService
      // For now, we'll create a placeholder implementation
      
      // Example implementation:
      // final formData = FormData.fromMap({
      //   'profile_picture': await MultipartFile.fromFile(
      //     imageFile.path,
      //     filename: 'profile_picture.jpg',
      //   ),
      // });
      // 
      // await ApiService.uploadFile('/upload-profile-picture', formData);
      
      // Placeholder - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      print('Profile picture uploaded: ${imageFile.path}');
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return _isLoading && _errorMessage == null
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : _buildProfileContent(authProvider);
        },
      ),
    );
  }
  
  Widget _buildProfileContent(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                // Profile picture
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Text(
                              _getInitials(authProvider.name ?? 'User'),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // User name
                Text(
                  authProvider.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // User role and department
                Text(
                  '${_capitalizeFirstLetter(authProvider.role ?? 'User')} - ${authProvider.department ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Profile form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email field (read-only)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  enabled: false, // Email cannot be changed
                ),
                
                const SizedBox(height: 16),
                
                // Contact number field
                TextFormField(
                  controller: _contactNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 32),
                
                // Actions
                Center(
                  child: _isEditing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _updateProfile,
                              icon: const Icon(Icons.save),
                              label: const Text('Save Changes'),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isEditing = false;
                                        _profileImage = null;
                                        _loadUserData();
                                      });
                                    },
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancel'),
                            ),
                          ],
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                ),
                
                const SizedBox(height: 32),
                
                // Account actions
                const Text(
                  'Account Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to change password screen
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _showLogoutDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
  
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $_errorMessage',
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchUserProfile,
            child: const Text('Retry'),
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
