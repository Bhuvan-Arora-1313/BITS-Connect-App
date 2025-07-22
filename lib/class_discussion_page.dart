import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'group_details_page.dart';

class RegularClassDiscussionPage extends StatefulWidget {
  const RegularClassDiscussionPage({super.key});

  @override
  State<RegularClassDiscussionPage> createState() => _RegularClassDiscussionPageState();
}

class _RegularClassDiscussionPageState extends State<RegularClassDiscussionPage> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> userCourses = [];
  List<DocumentSnapshot> relevantGroups = [];
  List<DocumentSnapshot> otherGroups = [];
  List<DocumentSnapshot> filteredRelevantGroups = [];
  List<DocumentSnapshot> filteredOtherGroups = [];
  bool isLoading = true;
  String searchQuery = "";
  String selectedFilter = 'today';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      userCourses = List<String>.from(userDoc.data()?['enrolledCourses'] ?? []);

      final snapshot = await FirebaseFirestore.instance
          .collection('study_groups')
          .where('tags', arrayContains: 'class discussion')
          .orderBy('startTime')
          .get();

      final now = DateTime.now();
      final scored = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final start = (data['startTime'] as Timestamp).toDate();
        final end = (data['endTime'] as Timestamp).toDate();
        final isPermanent = data['isPermanent'] == true;

        if (selectedFilter == 'today') {
          return start.year == now.year && start.month == now.month && start.day == now.day && !isPermanent;
        } else if (selectedFilter == 'upcoming') {
          final groupDate = DateTime(start.year, start.month, start.day);
          final todayDate = DateTime(now.year, now.month, now.day);
          return groupDate.isAfter(todayDate) && !isPermanent;
        } else if (selectedFilter == 'expired') {
          final groupDate = DateTime(start.year, start.month, start.day);
          final todayDate = DateTime(now.year, now.month, now.day);
          return groupDate.isBefore(todayDate) && !isPermanent;
        } else if (selectedFilter == 'permanent') {
          return isPermanent;
        }
        return false;
      }).map((doc) {
        final List<String> groupCourses = List<String>.from((doc.data() as Map<String, dynamic>)['courses'] ?? []);
        final int score = groupCourses.where((c) => userCourses.contains(c)).length;
        return MapEntry(doc, score);
      }).toList();

      scored.sort((a, b) => b.value.compareTo(a.value));

      setState(() {
        relevantGroups = scored.where((e) => e.value > 0).map((e) => e.key).toList();
        otherGroups = scored.where((e) => e.value == 0).map((e) => e.key).toList();
        filteredRelevantGroups = relevantGroups;
        filteredOtherGroups = otherGroups;
        isLoading = false;
      });
    } catch (e) {
      print("\u{1F525} ERROR in fetching class discussion groups: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterGroups(String query) {
    final q = query.toLowerCase();

    setState(() {
      filteredRelevantGroups = relevantGroups.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _matchesQuery(data, q);
      }).toList();

      filteredOtherGroups = otherGroups.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _matchesQuery(data, q);
      }).toList();
    });
  }

  bool _matchesQuery(Map<String, dynamic> data, String q) {
    final name = (data['groupName'] ?? '').toString().toLowerCase();
    final desc = (data['description'] ?? '').toString().toLowerCase();
    final creator = (data['creatorName'] ?? '').toString().toLowerCase();
    final courses = (data['courses'] as List<dynamic>?)?.cast<String>().join(' ').toLowerCase() ?? '';
    final startTime = (data['startTime'] as Timestamp).toDate();
    final timeStr = DateFormat.jm().format(startTime).toLowerCase();

    return name.contains(q) || desc.contains(q) || creator.contains(q) || courses.contains(q) || timeStr.contains(q);
  }

  Widget _buildFilterButtons() {
    final filters = {
      'today': 'Today',
      'upcoming': 'Upcoming',
      'expired': 'Expired',
      'permanent': 'Permanent'
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.entries.map((e) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(e.value),
              selected: selectedFilter == e.key,
              onSelected: (_) {
                setState(() {
                  selectedFilter = e.key;
                  isLoading = true;
                });
                _fetchData();
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildGroupCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final start = (data['startTime'] as Timestamp).toDate();
    final end = (data['endTime'] as Timestamp).toDate();
    final duration = end.difference(start);
    final now = DateTime.now();
    final isPermanent = data['isPermanent'] == true;

    Color statusColor;
    String statusLabel;
    if (isPermanent) {
      statusColor = Colors.blue;
      statusLabel = "Permanent";
    } else if (end.isBefore(now)) {
      statusColor = Colors.red;
      statusLabel = "Completed";
    } else if (start.isAfter(now)) {
      statusColor = Colors.yellow;
      statusLabel = "Upcoming";
    } else {
      statusColor = Colors.green;
      statusLabel = "Ongoing";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Text(data['groupName'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                CircleAvatar(radius: 6, backgroundColor: statusColor),
                const SizedBox(width: 6),
                Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12))
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: (data['courses'] as List<dynamic>?)?.map((c) => Chip(label: Text(c), backgroundColor: Colors.grey.shade100)).toList() ?? [],
            ),
            const SizedBox(height: 6),
            Text("⏰ ${DateFormat.jm().format(start)} for ${duration.inHours}h ${duration.inMinutes.remainder(60)}m",
                style: const TextStyle(color: Colors.black54))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(title: const Text("Class Discussion Groups")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    onChanged: (val) => _filterGroups(val),
                    decoration: InputDecoration(
                      hintText: "Search by group, subject, member, or time (e.g. 9 AM)",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                _buildFilterButtons(),
                Expanded(
                  child: ListView(
                    children: [
                      if (filteredRelevantGroups.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("📌 Relevant Study Groups",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        ...filteredRelevantGroups.map(_buildGroupCard).toList(),
                      ],
                      if (filteredOtherGroups.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("📁 Other Class Discussion Groups",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        ...filteredOtherGroups.map(_buildGroupCard).toList(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}