import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'complete_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_group_details_page.dart';
import 'landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// Import your screens here
import 'feed_page.dart';
import 'my_groups_page.dart';
import 'chats_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'login_screen.dart';
import 'group_details_page.dart';
import 'create_event_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GetTogetherApp());
}

class GetTogetherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      routes: {
        '/completeProfile': (context) => CompleteProfilePage(),
        '/create': (context) => CreateEventPage(),
        '/groupDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return GroupDetailsPage(
            groupId: args['groupId'],
            group: args['group'],
          );
        },
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final uid = snapshot.data!.uid;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final userDoc = userSnapshot.data!;

              // ✅ FIX: First check if document exists
              if (!userDoc.exists) {
                return CompleteProfilePage();
              }

              final profileCompleted = userDoc['profileCompleted'] ?? false;

              if (!profileCompleted) {
                return CompleteProfilePage();
              }

              return LandingPage(uid: uid);
            },
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    final List<Widget> _screens = [
      FeedPage(),
      MyGroupsPage(),
      ChatsPage(),
      NotificationsPage(userId: uid!),
      ProfilePage(uid: uid!),  // ✅ Now it's safe
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'My Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
