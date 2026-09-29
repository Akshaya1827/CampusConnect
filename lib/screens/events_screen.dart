import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_details_screen.dart';
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .snapshots(),

        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          // No events
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No events available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Display events
          final events = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,

            itemBuilder: (context, index) {
              final event =
              events[index].data() as Map<String, dynamic>;

              final eventId = events[index].id;
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(
                            event: event,
                            eventId: eventId,
                          ),
                        ),
                      );
                    },
                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        event['title'] ?? 'No title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        event['description'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Date: ${event['date'] ?? ''}',
                      ),

                      Text(
                        'Time: ${event['time'] ?? ''}',
                      ),

                      Text(
                        'Venue: ${event['venue'] ?? ''}',
                      ),

                      Text(
                        'Organizer: ${event['organizer'] ?? ''}',
                      ),
                    ],
                  ),
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