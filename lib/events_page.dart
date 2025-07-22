import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'group_details_page.dart';

class EventsGroupsPage extends StatefulWidget {
  const EventsGroupsPage({super.key});

  @override
  State<EventsGroupsPage> createState() => _EventsGroupsPageState();
}

class _EventsGroupsPageState extends State<EventsGroupsPage> {
  final user = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> groups = [];
  List<DocumentSnapshot> filteredGroups = [];
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
      final snapshot = await FirebaseFirestore.instance
          .collection('study_groups')
          .where('tags', arrayContains: 'Event')
          .orderBy('startTime')
          .get();

      final now = DateTime.now();

      final filtered = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final start = (data['startTime'] as Timestamp).toDate();
        final end = (data['endTime'] as Timestamp).toDate();
        final isPermanent = data['isPermanent'] == true;

        if (selectedFilter == 'today') {
          return start.day == now.day && start.month == now.month && start.year == now.year && !isPermanent;
        } else if (selectedFilter == 'upcoming') {
          return start.isAfter(now) && start.day != now.day && !isPermanent;
        } else if (selectedFilter == 'expired') {
          return end.isBefore(DateTime(now.year, now.month, now.day)) && !isPermanent;
        } else if (selectedFilter == 'permanent') {
          return isPermanent;
        }
        return false;
      }).toList();

      setState(() {
        groups = _sortByStatus(filtered);
        filteredGroups = groups;
        isLoading = false;
      });
    } catch (e) {
      print("🔥 ERROR in fetching event groups: $e");
      setState(() => isLoading = false);
    }
  }

  List<DocumentSnapshot> _sortByStatus(List<DocumentSnapshot> docs) {
    final now = DateTime.now();

    int getPriority(DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      final start = (data['startTime'] as Timestamp).toDate();
      final end = (data['endTime'] as Timestamp).toDate();
      final isPermanent = data['isPermanent'] == true;

      if (isPermanent) return 3;
      if (end.isBefore(now)) return 2; // Red
      if (start.isAfter(now)) return 1; // Yellow
      return 0; // Green
    }

    docs.sort((a, b) => getPriority(a).compareTo(getPriority(b)));
    return docs;
  }

  void _filterGroups(String query) {
    final q = query.toLowerCase();

    setState(() {
      filteredGroups = groups.where((doc) {
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

  Widget _buildFilterButtons() {
    final filters = {
      'today': 'Today',
      'upcoming': 'Upcoming',
      'expired': 'Expired',
      'permanent': 'Permanent'
    };

    return Container(
      height: 40,
      margin: const EdgeInsets.only(left: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(title: const Text("Event Groups")),
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
                  child: ListView.builder(
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) => _buildGroupCard(filteredGroups[index]),
                  ),
                ),
              ],
            ),
    );
  }
}