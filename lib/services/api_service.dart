import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for API calls
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Get token from shared preferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Get headers with authorization token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Handle API response
  static dynamic _handleResponse(http.Response response) {
    final responseData = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw Exception(responseData['error'] ?? 'Something went wrong');
    }
  }
  
  // Authentication APIs
  
  // Register user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String department,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'department': department,
      }),
    );
    
    return _handleResponse(response);
  }
  
  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    return _handleResponse(response);
  }
  
  // Get current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: headers,
    );
    
    return _handleResponse(response);
  }
  
  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: headers,
      body: json.encode(data),
    );
    
    return _handleResponse(response);
  }
  
  // Course APIs
  
  // Get all courses
  static Future<List<dynamic>> getCourses({
    String? department,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final headers = await _getHeaders();
    
    // Build query parameters
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (department != null) {
      queryParams['department'] = department;
    }
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    final uri = Uri.parse('$baseUrl/courses').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Get course by ID
  static Future<Map<String, dynamic>> getCourse(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/courses/$id'),
      headers: headers,
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Create course
  static Future<Map<String, dynamic>> createCourse(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: headers,
      body: json.encode(data),
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Update course
  static Future<Map<String, dynamic>> updateCourse(String id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/courses/$id'),
      headers: headers,
      body: json.encode(data),
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Delete course
  static Future<void> deleteCourse(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/courses/$id'),
      headers: headers,
    );
    
    _handleResponse(response);
  }
  
  // Get course semesters
  static Future<List<dynamic>> getCourseSemesters(String courseId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId/semesters'),
      headers: headers,
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Semester APIs
  
  // Get all semesters
  static Future<List<dynamic>> getSemesters({
    String? department,
    String? course,
    int? number,
    int page = 1,
    int limit = 10,
  }) async {
    final headers = await _getHeaders();
    
    // Build query parameters
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (department != null) {
      queryParams['department'] = department;
    }
    
    if (course != null) {
      queryParams['course'] = course;
    }
    
    if (number != null) {
      queryParams['number'] = number.toString();
    }
    
    final uri = Uri.parse('$baseUrl/semesters').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Get semester by ID
  static Future<Map<String, dynamic>> getSemester(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/semesters/$id'),
      headers: headers,
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Create semester
  static Future<Map<String, dynamic>> createSemester(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/semesters'),
      headers: headers,
      body: json.encode(data),
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Update semester
  static Future<Map<String, dynamic>> updateSemester(String id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/semesters/$id'),
      headers: headers,
      body: json.encode(data),
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Delete semester
  static Future<void> deleteSemester(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/semesters/$id'),
      headers: headers,
    );
    
    _handleResponse(response);
  }
  
  // Get semester subjects
  static Future<List<dynamic>> getSemesterSubjects(String semesterId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/semesters/$semesterId/subjects'),
      headers: headers,
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Subject APIs
  
  // Get all subjects
  static Future<List<dynamic>> getSubjects({
    String? department,
    String? semester,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final headers = await _getHeaders();
    
    // Build query parameters
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (department != null) {
      queryParams['department'] = department;
    }
    
    if (semester != null) {
      queryParams['semester'] = semester;
    }
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    final uri = Uri.parse('$baseUrl/subjects').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Get subject by ID
  static Future<Map<String, dynamic>> getSubject(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Create subject
  static Future<Map<String, dynamic>> createSubject(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/subjects'),
      headers: headers,
      body: json.encode(data),
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Update subject
  static Future<Map<String, dynamic>> updateSubject(String id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
      body: json.encode(data),
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Delete subject
  static Future<void> deleteSubject(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
    );
    
    _handleResponse(response);
  }
  
  // Get subject modules
  static Future<List<dynamic>> getSubjectModules(String subjectId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/subjects/$subjectId/modules'),
      headers: headers,
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Notice APIs
  
  // Get all notices
  static Future<List<dynamic>> getNotices({
    String? department,
    String? category,
    String? priority,
    String? search,
    bool? isActive,
    int page = 1,
    int limit = 10,
  }) async {
    final headers = await _getHeaders();
    
    // Build query parameters
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (department != null) {
      queryParams['department'] = department;
    }
    
    if (category != null) {
      queryParams['category'] = category;
    }
    
    if (priority != null) {
      queryParams['priority'] = priority;
    }
    
    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    final uri = Uri.parse('$baseUrl/notices').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Get notice by ID
  static Future<Map<String, dynamic>> getNotice(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/notices/$id'),
      headers: headers,
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Create notice
  static Future<Map<String, dynamic>> createNotice(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/notices'),
      headers: headers,
      body: json.encode(data),
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Update notice
  static Future<Map<String, dynamic>> updateNotice(String id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/notices/$id'),
      headers: headers,
      body: json.encode(data),
    );
    
    final responseData = _handleResponse(response);
    return responseData['data'];
  }
  
  // Delete notice
  static Future<void> deleteNotice(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/notices/$id'),
      headers: headers,
    );
    
    _handleResponse(response);
  }
}
