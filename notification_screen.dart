import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'icon': 'check_circle',
      'title': 'Booking Confirmed!',
      'subtitle': 'Your robe booking is confirmed! Collection date...',
      'timestamp': '03/12/2024  8:30 AM'
    },
    {
      'icon': 'event_note',
      'title': 'Don’t Forget Your Robe!',
      'subtitle': 'Your robe is ready for collection tomorrow...',
      'timestamp': '03/12/2024  8:30 AM'
    },
    {
      'icon': 'calendar_today',
      'title': 'Today’s the Day!',
      'subtitle': 'Remember to pick up your convocation robe...',
      'timestamp': '03/12/2024  8:30 AM'
    },
    {
      'icon': 'error_outline',
      'title': 'Return Your Robe Soon!',
      'subtitle': 'Your robe return deadline is approaching!...',
      'timestamp': '03/12/2024  8:30 AM'
    },
    {
      'icon': 'alarm',
      'title': 'Robe Return Overdue',
      'subtitle': 'Your robe return was due on [DD/MM/YYYY]...',
      'timestamp': '03/12/2024  8:30 AM'
    },
    {
      'icon': 'outstanding',
      'title': 'Outstanding Fine Reminder',
      'subtitle': 'Your robe return was due on [DD/MM/YYYY]...',
      'timestamp': '03/12/2024  8:30 AM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.blue),
            onPressed: () {
              // Action for notification icon
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    _getIcon(notification['icon']!),
                    size: 30,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        notification['subtitle']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        notification['timestamp']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'event_note':
        return Icons.event_note;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'error_outline':
        return Icons.error_outline;
      case 'alarm':
        return Icons.alarm;
      case 'outstanding':
        return Icons.attach_money;
      default:
        return Icons.notifications;
    }
  }
}
