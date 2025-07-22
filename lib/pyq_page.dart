import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'group_details_page.dart';

class PYQGroupsPage extends StatefulWidget {
  const PYQGroupsPage({super.key});

  @override
  State<PYQGroupsPage> createState() => _PYQGroupsPageState();
}

class _PYQGroupsPageState extends State<PYQGroupsPage> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> userCourses = [];
  List<DocumentSnapshot> relevantGroups = [];
  List<DocumentSnapshot> otherGroups = [];
  List<DocumentSnapshot> filteredRelevantGroups = [];
  List<DocumentSnapshot> filteredOtherGroups = [];
  bool isLoading = true;
  String searchQuery = "";
  int selectedFilter = 0; // 0: Today, 1: Upcoming, 2: Expired, 3: Permanent

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
          .where('tags', arrayContains: 'question practice')
          .orderBy('startTime')
          .get();

      final now = DateTime.now();
      final todayGroups = snapshot.docs.where((doc) {
        final start = (doc['startTime'] as Timestamp).toDate();
        return start.year == now.year && start.month == now.month && start.day == now.day;
      }).toList();

      final scored = todayGroups.map((doc) {
        final List<String> groupCourses = List<String>.from(doc['courses'] ?? []);
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
      print("\u{1F525} ERROR in fetching PYQ groups: $e");
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
 List<DocumentSnapshot> getFilteredGroups(List<DocumentSnapshot> groupList) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return groupList.where((doc) {
    final data = doc.data() as Map<String, dynamic>;
    final start = (data['startTime'] as Timestamp).toDate();
    final end = (data['endTime'] as Timestamp).toDate();
    final isPermanent = (data['tags'] as List?)?.contains('permanent') ?? false;

    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    if (selectedFilter == 0) {
      // Today's groups
      return startDate == today;
    } else if (selectedFilter == 1) {
      // Upcoming groups (future dates only)
      return startDate.isAfter(today);
    } else if (selectedFilter == 2) {
      // Expired groups (past dates only)
      return endDate.isBefore(today);
    } else if (selectedFilter == 3) {
      return isPermanent;
    }
    return true;
  }).toList();
}

  Widget _buildGroupCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final start = (data['startTime'] as Timestamp).toDate();
    final end = (data['endTime'] as Timestamp).toDate();
    final duration = end.difference(start);
    final now = DateTime.now();

    Color statusColor;
    String statusLabel;
    if (end.isBefore(now)) {
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
      appBar: AppBar(title: const Text("Question Practice Groups")),
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
                Expanded(
  child: Column(
    children: [
      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        const SizedBox(width: 4),
        FilterChip(
          label: const Text("Today's"),
          selected: selectedFilter == 0,
          onSelected: (_) => setState(() => selectedFilter = 0),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text("Upcoming"),
          selected: selectedFilter == 1,
          onSelected: (_) => setState(() => selectedFilter = 1),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text("Expired"),
          selected: selectedFilter == 2,
          onSelected: (_) => setState(() => selectedFilter = 2),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text("Permanent"),
          selected: selectedFilter == 3,
          onSelected: (_) => setState(() => selectedFilter = 3),
        ),
        const SizedBox(width: 4),
      ],
    ),
  ),
),
      Expanded(
        child: ListView(
          children: [
            if (getFilteredGroups(filteredRelevantGroups).isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("📌 Relevant Study Groups",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...getFilteredGroups(filteredRelevantGroups).map(_buildGroupCard).toList(),
            ],
            if (getFilteredGroups(filteredOtherGroups).isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("📁 Other Question Practice Groups",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...getFilteredGroups(filteredOtherGroups).map(_buildGroupCard).toList(),
            ],
          ],
        ),
      ),
    ],
  ),
),
              ],
            ),
    );
  }
}
