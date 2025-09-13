import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';

class NoticeCard extends StatelessWidget {
  final String id;
  final String title;
  final String content;
  final String department;
  final String category;
  final String priority;
  final DateTime publishDate;
  final DateTime? expiryDate;
  final List<dynamic> attachments;
  final VoidCallback onTap;
  final bool showActions;

  const NoticeCard({
    Key? key,
    required this.id,
    required this.title,
    required this.content,
    required this.department,
    required this.category,
    required this.priority,
    required this.publishDate,
    this.expiryDate,
    required this.attachments,
    required this.onTap,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice header with priority indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getPriorityColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadius),
                  topRight: Radius.circular(AppTheme.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Published: ${DateFormat('MMM dd, yyyy').format(publishDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _capitalizeFirstLetter(priority),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Notice content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category and department
                  Row(
                    children: [
                      _buildInfoChip(
                        label: _capitalizeFirstLetter(category),
                        icon: Icons.category,
                        color: _getCategoryColor(),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        label: department,
                        icon: Icons.business,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  
                  // Attachments
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${attachments.length} ${attachments.length == 1 ? 'attachment' : 'attachments'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            if (showActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                      onPressed: onTap,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }
  
  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'academic':
        return Colors.purple;
      case 'exam':
        return Colors.red;
      case 'event':
        return Colors.green;
      case 'holiday':
        return Colors.orange;
      case 'general':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}