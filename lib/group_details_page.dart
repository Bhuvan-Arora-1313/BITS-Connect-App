import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';
import 'edit_group_details_page.dart';
import 'group_chat_page.dart';

class GroupDetailsPage extends StatefulWidget {
  final Map<String, dynamic> group;
  final String groupId;

  GroupDetailsPage({required this.group, required this.groupId});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  Map<String, dynamic>? updatedGroup;

  @override
  void initState() {
    super.initState();
    updatedGroup = widget.group;
  }

  @override
  Widget build(BuildContext context) {
    final isCreator = updatedGroup!['createdBy'] == user?.uid;
    final members = List<String>.from(updatedGroup!['members'] ?? []);
    final pending = List<String>.from(updatedGroup!['pendingRequests'] ?? []);
    final isRequested = pending.contains(user?.uid);
    final isMember = members.contains(user?.uid);
    final tags = List<String>.from(updatedGroup!['tags'] ?? []);
    final courses = List<String>.from(updatedGroup!['courses'] ?? []);

    final startTime = (updatedGroup!['startTime'] as Timestamp).toDate();
    final endTime = (updatedGroup!['endTime'] as Timestamp).toDate();
    final now = DateTime.now();
    final duration = endTime.difference(startTime);
    final durationStr = "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";

    Color statusColor;
    if (endTime.isBefore(now)) {
      statusColor = Colors.red;
    } else if (startTime.isAfter(now)) {
      statusColor = Colors.yellow;
    } else {
      statusColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: Text(updatedGroup!['groupName'] ?? 'Group')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      updatedGroup!['groupName'] ?? '',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  CircleAvatar(radius: 8, backgroundColor: statusColor),
                                ],
                              ),
                              if (updatedGroup!['isPermanent'] == true)
  Padding(
    padding: const EdgeInsets.only(top: 6.0),
    child: Row(
      children: [
        Icon(Icons.push_pin, size: 18, color: Colors.deepPurple),
        SizedBox(width: 6),
        Text("This is a permanent group", style: TextStyle(color: Colors.deepPurple)),
      ],
    ),
  ),
                              SizedBox(height: 10),
                              Text("${updatedGroup!['description'] ?? ''}", style: TextStyle(fontSize: 16)),
                              SizedBox(height: 10),
                              if (tags.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: tags.map((tag) => Chip(label: Text(tag))).toList(),
                                ),
                              SizedBox(height: 10),
                              if (courses.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [Icon(Icons.book, size: 18), SizedBox(width: 6), Text("Courses:")]),
                                    SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: courses.map((course) => Chip(
                                          label: Text(course),
                                          backgroundColor: Colors.indigo.shade50,
                                          labelStyle: TextStyle(color: Colors.indigo.shade900),
                                        )).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 10),
                              Row(children: [Icon(Icons.lock_open, size: 18), SizedBox(width: 6), Text("Visibility: ${updatedGroup!['isPublic'] ? 'Public' : 'Restricted'}")]),
                              Row(children: [Icon(Icons.place, size: 18), SizedBox(width: 6), Text("Location: ${updatedGroup!['location'] ?? 'N/A'}")]),
                              Row(children: [Icon(Icons.access_time, size: 18), SizedBox(width: 6), Text("Start: ${DateFormat.yMd().add_jm().format(startTime)}")]),
                              Row(children: [Icon(Icons.timer, size: 18), SizedBox(width: 6), Text("Duration: $durationStr")]),
                            ],
                          ),
                        ),
                      ),
                      Text("Members:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ...members.map((uid) => FutureBuilder<String>(
                            future: _getUsername(uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return ListTile(title: Text("Loading..."));
                              if (snapshot.hasData) {
                                return ListTile(
                                  leading: Icon(Icons.person),
                                  title: Row(
  children: [
    Text(snapshot.data!),
    if (uid == updatedGroup!['createdBy'])
      Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Icon(Icons.emoji_events, size: 18, color: Colors.amber),
      )
  ],
),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
                                  ),
                                  trailing: isCreator && uid != user!.uid
                                      ? IconButton(
                                          icon: Icon(Icons.remove_circle, color: Colors.red),
                                          onPressed: () => _removeMember(uid),
                                        )
                                      : null,
                                );
                              } else {
                                return ListTile(title: Text("Error loading username"));
                              }
                            },
                          )),
                      if (isCreator && pending.isNotEmpty) ...[
                        Divider(height: 30),
                        Text("Join Requests:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ...pending.map((uid) => FutureBuilder<String>(
                              future: _getUsername(uid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) return ListTile(title: Text("Loading..."));
                                if (snapshot.hasData) {
                                  return ListTile(
                                    leading: Icon(Icons.person_outline),
                                    title: Text(snapshot.data!),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.check_circle, color: Colors.green),
                                          onPressed: () => _approveRequest(uid),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.cancel, color: Colors.red),
                                          onPressed: () => _rejectRequest(uid),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return ListTile(title: Text("Error loading username"));
                                }
                              },
                            )),
                      ],
                      if (!isCreator) ...[
                        Divider(height: 30),
                        Center(
                          child: isRequested
                              ? Text("Request Sent", style: TextStyle(color: Colors.orange))
                              : isMember
                                  ? ElevatedButton.icon(
                                      icon: Icon(Icons.exit_to_app),
                                      label: Text("Leave Group"),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: _handleLeave,
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _handleJoin,
                                      icon: Icon(Icons.group_add),
                                      label: Text(updatedGroup!['isPublic'] ? 'Join' : 'Request to Join'),
                                    ),
                        )
                      ],
                      if (isCreator) ...[
                        Divider(height: 30),
                        ElevatedButton.icon(
                          icon: Icon(Icons.edit),
                          label: Text("Edit Group Details"),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditGroupDetailsPage(groupId: widget.groupId),
                              ),
                            );
                            await _refreshGroupData();
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: Icon(Icons.delete_forever),
                          label: Text("Dismiss Group"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: _dismissGroup,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isMember)
                  Positioned(
                    bottom: 10,
                    left: 16,
                    right: 16,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.chat_bubble_outline),
                      label: Text("Chat with Group"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupChatPage(groupId: widget.groupId, groupName: updatedGroup!['groupName']),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _refreshGroupData() async {
    final doc = await FirebaseFirestore.instance.collection('study_groups').doc(widget.groupId).get();
    setState(() {
      updatedGroup = doc.data()!;
    });
  }

  Future<String> _getUsername(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data()?['username'] ?? uid;
  }

  Future<void> _sendNotification(String userId, String message, String type) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'content': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _removeMember(String uid) async {
    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('study_groups').doc(widget.groupId).update({
      'members': FieldValue.arrayRemove([uid])
    });
    await _sendNotification(uid, 'You have been removed from the group: ${updatedGroup!['groupName']}', 'Member Removed');
    await _refreshGroupData();
    setState(() => isLoading = false);
  }

  Future<void> _approveRequest(String uid) async {
    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('study_groups').doc(widget.groupId).update({
      'pendingRequests': FieldValue.arrayRemove([uid]),
      'members': FieldValue.arrayUnion([uid])
    });
    await _sendNotification(uid, 'Your request to join ${updatedGroup!['groupName']} has been approved.', 'Request Approved');
    await _refreshGroupData();
    setState(() => isLoading = false);
  }

  Future<void> _rejectRequest(String uid) async {
    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('study_groups').doc(widget.groupId).update({
      'pendingRequests': FieldValue.arrayRemove([uid])
    });
    await _sendNotification(uid, 'Your request to join ${updatedGroup!['groupName']} has been rejected.', 'Request Rejected');
    await _refreshGroupData();
    setState(() => isLoading = false);
  }

  Future<void> _handleJoin() async {
    setState(() => isLoading = true);
    final groupRef = FirebaseFirestore.instance.collection('study_groups').doc(widget.groupId);
    if (updatedGroup!['isPublic']) {
      await groupRef.update({ 'members': FieldValue.arrayUnion([user?.uid]) });
      await _sendNotification(user!.uid, 'You joined ${updatedGroup!['groupName']}', 'New Member');
    } else {
      await groupRef.update({ 'pendingRequests': FieldValue.arrayUnion([user?.uid]) });
      await _sendNotification(updatedGroup!['createdBy'], '${user!.uid} requested to join ${updatedGroup!['groupName']}', 'Join Request');
    }
    await _refreshGroupData();
    setState(() => isLoading = false);
  }

  Future<void> _handleLeave() async {
    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('study_groups').doc(widget.groupId).update({
      'members': FieldValue.arrayRemove([user!.uid])
    });
    await _sendNotification(updatedGroup!['createdBy'], '${user!.uid} has left the group: ${updatedGroup!['groupName']}', 'Left Group');
    await _refreshGroupData();
    setState(() => isLoading = false);
  }

  Future<void> _dismissGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you want to dismiss this group?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );

    if (confirm == true) {
      for (var member in updatedGroup!['members']) {
        await _sendNotification(member, 'The group ${updatedGroup!['groupName']} has been dismissed.', 'Group Dismissed');
      }
      await FirebaseFirestore.instance.collection('study_groups').doc(widget.groupId).delete();
      Navigator.pop(context);
    }
  }
}
