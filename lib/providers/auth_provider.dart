import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../services/api_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  String? _token;
  String? _userId;
  String? _name;
  String? _email;
  String? _role;
  String? _department;
  final SharedPreferences _prefs;
  
  AuthProvider(this._prefs) {
    _loadUserData();
  }
  
  AuthStatus get status => _status;
  String? get token => _token;
  String? get userId => _userId;
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;
  String? get department => _department;
  
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _role == AppConfig.roleAdmin;
  bool get isFaculty => _role == AppConfig.roleFaculty;
  bool get isStudent => _role == AppConfig.roleStudent;
  
  Future<void> _loadUserData() async {
    _token = _prefs.getString(AppConfig.tokenKey);
    _userId = _prefs.getString(AppConfig.userIdKey);
    _name = _prefs.getString(AppConfig.nameKey);
    _email = _prefs.getString(AppConfig.emailKey);
    _role = _prefs.getString(AppConfig.roleKey);
    _department = _prefs.getString(AppConfig.departmentKey);
    
    if (_token != null && _userId != null) {
      try {
        // Verify token validity by getting current user
        final userData = await ApiService.getCurrentUser();
        
        // Update user data
        _userId = userData['data']['_id'];
        _name = userData['data']['name'];
        _email = userData['data']['email'];
        _role = userData['data']['role'];
        _department = userData['data']['department'];
        
        // Save updated user data
        await _saveUserData();
        
        _status = AuthStatus.authenticated;
      } catch (e) {
        // Token is invalid or expired
        await logout();
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }
  
  Future<void> _saveUserData() async {
    if (_token != null) await _prefs.setString(AppConfig.tokenKey, _token!);
    if (_userId != null) await _prefs.setString(AppConfig.userIdKey, _userId!);
    if (_name != null) await _prefs.setString(AppConfig.nameKey, _name!);
    if (_email != null) await _prefs.setString(AppConfig.emailKey, _email!);
    if (_role != null) await _prefs.setString(AppConfig.roleKey, _role!);
    if (_department != null) await _prefs.setString(AppConfig.departmentKey, _department!);
  }
  
  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );
      
      _token = response['token'];
      _userId = response['user']['_id'];
      _name = response['user']['name'];
      _email = response['user']['email'];
      _role = response['user']['role'];
      _department = response['user']['department'];
      
      await _saveUserData();
      
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String department,
  }) async {
    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        department: department,
      );
      
      _token = response['token'];
      _userId = response['user']['_id'];
      _name = response['user']['name'];
      _email = response['user']['email'];
      _role = response['user']['role'];
      _department = response['user']['department'];
      
      await _saveUserData();
      
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _name = null;
    _email = null;
    _role = null;
    _department = null;
    
    await _prefs.remove(AppConfig.tokenKey);
    await _prefs.remove(AppConfig.userIdKey);
    await _prefs.remove(AppConfig.nameKey);
    await _prefs.remove(AppConfig.emailKey);
    await _prefs.remove(AppConfig.roleKey);
    await _prefs.remove(AppConfig.departmentKey);
    
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
  
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.updateProfile(data);
      
      _name = response['data']['name'];
      _email = response['data']['email'];
      
      await _prefs.setString(AppConfig.nameKey, _name!);
      await _prefs.setString(AppConfig.emailKey, _email!);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}