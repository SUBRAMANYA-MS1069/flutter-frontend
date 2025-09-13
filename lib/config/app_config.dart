class AppConfig {
  // App information
  static const String appName = 'Educational CMS';
  static const String appVersion = '1.0.0';
  
  // API configuration
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api'; // For Android emulator
  // static const String apiBaseUrl = 'http://localhost:5000/api'; // For iOS simulator
  // static const String apiBaseUrl = 'https://your-production-api.com/api'; // For production
  
  // Timeout durations
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // File upload limits
  static const int maxFileSize = 25 * 1024 * 1024; // 25MB
  
  // Supported file types
  static const List<String> supportedDocumentTypes = [
    'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'
  ];
  
  // Department list
  static const List<String> departments = [
    'CSE', 'ECE', 'MECH', 'CIVIL', 'EEE', 'IT', 'OTHER'
  ];
  
  // User roles
  static const String roleAdmin = 'admin';
  static const String roleFaculty = 'faculty';
  static const String roleStudent = 'student';
  
  // Shared preferences keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';
  static const String nameKey = 'name';
  static const String emailKey = 'email';
  static const String roleKey = 'role';
  static const String departmentKey = 'department';
  static const String themeKey = 'theme';
}