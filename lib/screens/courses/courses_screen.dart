import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_search_bar.dart';
import '../../widgets/course/course_card.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;
  
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMoreData = true;
  
  @override
  void initState() {
    super.initState();
    _fetchCourses();
    
    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _loadMoreCourses();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final department = authProvider.isAdmin ? null : authProvider.department;
      
      final courses = await ApiService.getCourses(
        department: department,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: 1,
      );
      
      setState(() {
        _courses = courses;
        _isLoading = false;
        _currentPage = 1;
        _hasMoreData = courses.length >= 10; // Assuming default page size is 10
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMoreCourses() async {
    if (!_hasMoreData || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final department = authProvider.isAdmin ? null : authProvider.department;
      
      final nextPage = _currentPage + 1;
      final moreCourses = await ApiService.getCourses(
        department: department,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: nextPage,
      );
      
      if (moreCourses.isNotEmpty) {
        setState(() {
          _courses.addAll(moreCourses);
          _currentPage = nextPage;
          _hasMoreData = moreCourses.length >= 10; // Assuming default page size is 10
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      // Just log the error, don't update error message to avoid disrupting the UI
      print('Error loading more courses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _onSearch(String query) {
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
      });
      _fetchCourses();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Search courses...',
              onSearch: _onSearch,
            ),
          ),
          
          // Courses list
          Expanded(
            child: _errorMessage != null
                ? _buildErrorWidget()
                : _isLoading && _courses.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _courses.isEmpty
                        ? _buildEmptyWidget()
                        : _buildCoursesList(),
          ),
        ],
      ),
      floatingActionButton: (authProvider.isAdmin || authProvider.isFaculty)
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to add course screen
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildCoursesList() {
    return RefreshIndicator(
      onRefresh: _fetchCourses,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: _courses.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _courses.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final course = _courses[index];
          return CourseCard(
            id: course['_id'],
            name: course['name'],
            code: course['code'],
            department: course['department'],
            description: course['description'] ?? 'No description available',
            faculty: course['faculty'] ?? [],
            onTap: () {
              // Navigate to course details screen
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No courses available'
                : 'No courses found for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                _fetchCourses();
              },
              child: const Text('Clear search'),
            ),
        ],
      ),
    );
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
            onPressed: _fetchCourses,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}