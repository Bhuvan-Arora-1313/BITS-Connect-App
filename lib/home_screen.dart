import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'create_event_page.dart';
import 'event_feed_page.dart';
import 'feed_page.dart';
import 'my_groups_page.dart';
import 'chats_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome!')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Logout"),
              onPressed: () async {
                await AuthService().signOut();
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("➕ Create Event"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEventPage()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("📋 View Events"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventFeedPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}