import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this is added


class NotificationsPage extends StatelessWidget {
  final String userId;

  NotificationsPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true) // Get most recent notifications
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications yet.'));
          }

          final notifications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (ctx, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification['content']),
                subtitle: Text(notification['type']),
                trailing: Icon(Icons.notifications),
              );
            },
          );
        },
      ),
    );
  }
}