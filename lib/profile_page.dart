// lib/profile_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart'; 
import 'edit_profile_page.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({required this.uid, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToEditPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(uid: widget.uid)),
    );
    _loadProfile(); // refresh after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          if (widget.uid == currentUser?.uid) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Profile',
              onPressed: _navigateToEditPage,
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () async {
                await AuthService().signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthGate()),
                  (route) => false,
                );
              },
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text('User not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData!['name'] ?? '',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${userData!['username']}',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            _infoRow("BITS ID", userData!['bitsId']),
                            _infoRow("Email", userData!['email']),
                            _infoRow("Gender", userData!['gender']),
                            _infoRow("Year of Study", userData!['yearOfStudy']),
                            _infoRow("Phone", userData!['phone']),
                            _infoRow("Hostel", userData!['hostel']),
                            _infoRow("Clubs", userData!['clubs']),
                            _infoRow("Bio", userData!['bio']),
                            _infoRow(
                              "CGPA",
                              userData!['cgpaPublic'] == true || widget.uid == currentUser?.uid
                                  ? userData!['cgpa']
                                  : "Hidden",
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Courses
                    Text(
                      "Enrolled Courses",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: List<Widget>.from(
                        (userData!['enrolledCourses'] ?? []).map(
                          (course) => Chip(
                            label: Text(course),
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _infoRow(String title, dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) return SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}