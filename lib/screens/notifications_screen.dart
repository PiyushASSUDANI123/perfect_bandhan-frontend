import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final notifications = await auth.getUserNotifications();
    auth.markAllNotificationsAsRead();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textCarbon),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOTIFICATIONS',
          style: GoogleFonts.cinzel(
            color: AppTheme.textCarbon,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No Notifications Yet',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textCarbon,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We will notify you of important updates here.',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_active, color: AppTheme.accentGold),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['title'] ?? 'Notification',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.textCarbon,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification['body'] ?? '',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notification['createdAt'] != null ? _formatDate(notification['createdAt']) : '',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () async {
                                final auth = Provider.of<AuthProvider>(context, listen: false);
                                final success = await auth.deleteUserNotification(notification['_id']);
                                if (success && mounted) {
                                  setState(() {
                                    _notifications.removeWhere((n) => n['_id'] == notification['_id']);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
