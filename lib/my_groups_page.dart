import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'group_details_page.dart';
import 'profile_page.dart';

class MyGroupsPage extends StatefulWidget {
  @override
  State<MyGroupsPage> createState() => _MyGroupsPageState();
}

class _MyGroupsPageState extends State<MyGroupsPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool createdExpanded = true;
  bool joinedExpanded = true;
  bool requestedExpanded = true;
  bool expiredExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text("Not logged in"));

    final uid = user!.uid;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final createdGroupsQuery = FirebaseFirestore.instance
        .collection('study_groups')
        .where('createdBy', isEqualTo: uid);

    final joinedGroupsQuery = FirebaseFirestore.instance
        .collection('study_groups')
        .where('members', arrayContains: uid);

    final requestedGroupsQuery = FirebaseFirestore.instance
        .collection('study_groups')
        .where('pendingRequests', arrayContains: uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text("My Study Groups"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Study Group',
            onPressed: () => Navigator.pushNamed(context, '/create'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCollapsibleSection("\ud83d\udccc Groups I Created", createdGroupsQuery, uid, true, createdExpanded, (v) => setState(() => createdExpanded = v), today),
            const Divider(height: 40),
            _buildCollapsibleSection("\ud83d\udc65 Groups I Joined", joinedGroupsQuery, uid, false, joinedExpanded, (v) => setState(() => joinedExpanded = v), today),
            const Divider(height: 40),
            _buildRequestedSection("\u23f3 Groups I Requested", requestedGroupsQuery, uid, requestedExpanded, (v) => setState(() => requestedExpanded = v), today),
            const Divider(height: 40),
            _buildExpiredSection("\ud83d\udcc1 Expired Groups", uid, expiredExpanded, (v) => setState(() => expiredExpanded = v), today),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection(String title, Query query, String uid, bool isCreated, bool expanded, void Function(bool) onToggle, DateTime today) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(title, expanded, onToggle),
        if (expanded)
          StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final end = (data['endTime'] as Timestamp).toDate();
                return end.isAfter(today);
              }).toList();
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(isCreated ? "No groups created." : "No groups joined.", style: const TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) => _buildGroupCard(docs[i], uid, isCreated),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRequestedSection(String title, Query query, String uid, bool expanded, void Function(bool) onToggle, DateTime today) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(title, expanded, onToggle),
        if (expanded)
          StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final filtered = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final end = (data['endTime'] as Timestamp).toDate();
                return end.isAfter(today);
              }).toList();
              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("No pending requests.", style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                itemCount: filtered.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  final doc = filtered[i];
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['groupName'] ?? 'Unnamed Group'),
                    subtitle: Text("Created by ${data['creatorName']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () async {
                        await doc.reference.update({
                          'pendingRequests': FieldValue.arrayRemove([uid])
                        });
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailsPage(group: data, groupId: doc.id),
                      ),
                    ),
                  );
                },
              );
            },
          )
      ],
    );
  }

  Widget _buildExpiredSection(String title, String uid, bool expanded, void Function(bool) onToggle, DateTime today) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(title, expanded, onToggle),
        if (expanded)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('study_groups').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final expired = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final end = (data['endTime'] as Timestamp).toDate();
                final isExpired = end.isBefore(today);
                final isCreated = data['createdBy'] == uid;
                final isJoined = (data['members'] ?? []).contains(uid);
                final isRequested = (data['pendingRequests'] ?? []).contains(uid);
                return isExpired && (isCreated || isJoined || isRequested);
              }).toList();
              if (expired.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("No expired groups found.", style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                itemCount: expired.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) => _buildGroupCard(expired[i], uid, false),
              );
            },
          ),
      ],
    );
  }

  Widget _buildHeader(String title, bool expanded, void Function(bool) onToggle) {
    return GestureDetector(
      onTap: () => onToggle(!expanded),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Icon(expanded ? Icons.expand_less : Icons.expand_more)
        ],
      ),
    );
  }

  Widget _buildGroupCard(DocumentSnapshot doc, String uid, bool isCreatorView) {
    final data = doc.data() as Map<String, dynamic>;
    final start = (data['startTime'] as Timestamp).toDate();
    final end = (data['endTime'] as Timestamp).toDate();
    final duration = end.difference(start);
    final now = DateTime.now();
    final status = end.isBefore(now)
        ? [Colors.red, "Completed"]
        : start.isAfter(now)
            ? [Colors.yellow, "Upcoming"]
            : [Colors.green, "Ongoing"];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupDetailsPage(group: data, groupId: doc.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(data['groupName'] ?? "Unnamed Group",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                CircleAvatar(radius: 6, backgroundColor: status[0] as Color),
                const SizedBox(width: 6),
                Text(status[1] as String, style: TextStyle(color: status[0] as Color, fontSize: 12))
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: (data['courses'] as List?)?.map((c) => Chip(label: Text(c))).toList().cast<Widget>() ?? [],
            ),
            const SizedBox(height: 6),
            Text("\u23F0 ${DateFormat.jm().format(start)} for ${duration.inHours}h ${duration.inMinutes.remainder(60)}m",
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(uid: data['createdBy']),
                    ),
                  ),
                  child: Text("By ${data['creatorName'] ?? 'Unknown'}",
                      style: const TextStyle(color: Colors.blue)),
                ),
                Row(
                  children: [
                    const Icon(Icons.group, size: 16),
                    const SizedBox(width: 4),
                    Text("${(data['members'] ?? []).length}"),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
