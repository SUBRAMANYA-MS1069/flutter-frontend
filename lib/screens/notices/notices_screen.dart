import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_search_bar.dart';
import '../../widgets/notice/notice_card.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({Key? key}) : super(key: key);

  @override
  _NoticesScreenState createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  List<dynamic> _notices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;
  String? _selectedCategory;
  String? _selectedPriority;
  
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMoreData = true;
  
  final List<String> _categories = [
    'All',
    'Academic',
    'Exam',
    'Event',
    'Holiday',
    'General',
    'Other',
  ];
  
  final List<String> _priorities = [
    'All',
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];
  
  @override
  void initState() {
    super.initState();
    _fetchNotices();
    
    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _loadMoreNotices();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchNotices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final department = authProvider.isAdmin ? null : authProvider.department;
      
      final notices = await ApiService.getNotices(
        department: department,
        category: _selectedCategory != null && _selectedCategory != 'All'
            ? _selectedCategory!.toLowerCase()
            : null,
        priority: _selectedPriority != null && _selectedPriority != 'All'
            ? _selectedPriority!.toLowerCase()
            : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        isActive: true,
        page: 1,
      );
      
      setState(() {
        _notices = notices;
        _isLoading = false;
        _currentPage = 1;
        _hasMoreData = notices.length >= 10; // Assuming default page size is 10
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMoreNotices() async {
    if (!_hasMoreData || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final department = authProvider.isAdmin ? null : authProvider.department;
      
      final nextPage = _currentPage + 1;
      final moreNotices = await ApiService.getNotices(
        department: department,
        category: _selectedCategory != null && _selectedCategory != 'All'
            ? _selectedCategory!.toLowerCase()
            : null,
        priority: _selectedPriority != null && _selectedPriority != 'All'
            ? _selectedPriority!.toLowerCase()
            : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        isActive: true,
        page: nextPage,
      );
      
      if (moreNotices.isNotEmpty) {
        setState(() {
          _notices.addAll(moreNotices);
          _currentPage = nextPage;
          _hasMoreData = moreNotices.length >= 10; // Assuming default page size is 10
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      // Just log the error, don't update error message to avoid disrupting the UI
      print('Error loading more notices: $e');
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
      _fetchNotices();
    }
  }
  
  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchNotices();
  }
  
  void _onPriorityChanged(String? priority) {
    setState(() {
      _selectedPriority = priority;
    });
    _fetchNotices();
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
              hintText: 'Search notices...',
              onSearch: _onSearch,
            ),
          ),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Category filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory ?? 'All',
                      hint: const Text('Category'),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: _onCategoryChanged,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Priority filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPriority ?? 'All',
                      hint: const Text('Priority'),
                      items: _priorities.map((priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: _onPriorityChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Notices list
          Expanded(
            child: _errorMessage != null
                ? _buildErrorWidget()
                : _isLoading && _notices.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _notices.isEmpty
                        ? _buildEmptyWidget()
                        : _buildNoticesList(),
          ),
        ],
      ),
      floatingActionButton: (authProvider.isAdmin || authProvider.isFaculty)
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to add notice screen
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildNoticesList() {
    return RefreshIndicator(
      onRefresh: _fetchNotices,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: _notices.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notices.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final notice = _notices[index];
          return NoticeCard(
            id: notice['_id'],
            title: notice['title'],
            content: notice['content'],
            department: notice['department'],
            category: notice['category'],
            priority: notice['priority'],
            publishDate: DateTime.parse(notice['publishDate']),
            expiryDate: notice['expiryDate'] != null
                ? DateTime.parse(notice['expiryDate'])
                : null,
            attachments: notice['attachments'] ?? [],
            onTap: () {
              // Navigate to notice details screen
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
            Icons.announcement_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No notices available'
                : 'No notices found for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty || _selectedCategory != null || _selectedPriority != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = null;
                  _selectedPriority = null;
                });
                _fetchNotices();
              },
              child: const Text('Clear filters'),
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
            onPressed: _fetchNotices,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}