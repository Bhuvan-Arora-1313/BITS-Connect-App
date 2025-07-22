// lib/feed_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group_details_page.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _searchController = TextEditingController();
  List<DocumentSnapshot> _allGroups = [];
  List<DocumentSnapshot> _filteredGroups = [];
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    final snapshot = await FirebaseFirestore.instance.collection('study_groups').orderBy('createdAt', descending: true).get();
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final enrolledCourses = List<String>.from(userDoc.data()?['enrolledCourses'] ?? []);

    _allGroups = snapshot.docs;
    _filteredGroups = _sortGroupsByRelevance(_allGroups, enrolledCourses);
    setState(() {});
  }

  List<DocumentSnapshot> _sortGroupsByRelevance(List<DocumentSnapshot> groups, List<String> userCourses) {
    final relevant = <DocumentSnapshot>[];
    final others = <DocumentSnapshot>[];

    for (final doc in groups) {
      final courses = List<String>.from(doc['courses'] ?? []);
      if (courses.any((course) => userCourses.contains(course))) {
        relevant.add(doc);
      } else {
        others.add(doc);
      }
    }
    return [...relevant, ...others];
  }

  void _searchGroups(String query) {
    final results = _allGroups.where((doc) {
      final name = doc['groupName'].toString().toLowerCase();
      final description = doc['description'].toString().toLowerCase();
      final courses = List<String>.from(doc['courses'] ?? []).join(' ').toLowerCase();
      return name.contains(query.toLowerCase()) ||
             description.contains(query.toLowerCase()) ||
             courses.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredGroups = results;
    });
  }

  Future<void> _handleJoin(DocumentSnapshot group) async {
    final isPublic = group['isPublic'] ?? true;
    final groupRef = FirebaseFirestore.instance.collection('study_groups').doc(group.id);

    if (isPublic) {
      await groupRef.update({
        'members': FieldValue.arrayUnion([uid])
      });
    } else {
      await groupRef.update({
        'pendingRequests': FieldValue.arrayUnion([uid])
      });
    }
    _fetchGroups();
  }
  Future<void> _handleLeave(DocumentSnapshot group) async {
  final groupRef = FirebaseFirestore.instance.collection('study_groups').doc(group.id);
  await groupRef.update({
    'members': FieldValue.arrayRemove([uid])
  });
  _fetchGroups(); // Refresh the list after leaving
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search groups...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _searchGroups,
            ),
          ),
        ),
      ),
      body: _filteredGroups.isEmpty
          ? Center(child: Text("No groups found."))
          : ListView.builder(
              itemCount: _filteredGroups.length,
              itemBuilder: (context, index) {
                final doc = _filteredGroups[index];
                final isMember = List<String>.from(doc['members'] ?? []).contains(uid);
                final isRequested = List<String>.from(doc['pendingRequests'] ?? []).contains(uid);
                return ListTile(
                  title: Text(doc['groupName'] ?? 'Unnamed'),
                  subtitle: Text(doc['description'] ?? ''),
                  trailing: isMember
                        ? TextButton(
                            onPressed: () => _handleLeave(doc),
                            child: Text("Leave", style: TextStyle(color: Colors.red)),
                        )
                      : isRequested
                          ? Text("Requested", style: TextStyle(color: Colors.orange))
                          : TextButton(
                              child: Text(doc['isPublic'] ? 'Join' : 'Request'),
                              onPressed: () => _handleJoin(doc),
                            ),
                  onTap: () {
  final data = doc.data() as Map<String, dynamic>; // ✅ define it here
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GroupDetailsPage(
        groupId: doc.id,
        group: data,
      ),
    ),
  );
},
                );
              },
            ),
    );
  }
}
