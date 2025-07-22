import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventFeedPage extends StatelessWidget {
  const EventFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upcoming Events')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('study_groups')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          if (events.isEmpty) {
            return Center(child: Text('No events yet 😢'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(event['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['description']),
                      Text('📍 ${event['location']}'),
                      Text('📅 ${event['date'].toDate().toLocal().toString().split(' ')[0]}'),
                    ],
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