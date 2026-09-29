import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.eventId,
  });

  Future<void> registerForEvent(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
        ),
      );
      return;
    }

    try {
      final registrationId = '${eventId}_${user.uid}';

      await FirebaseFirestore.instance
          .collection('eventRegistrations')
          .doc(registrationId)
          .set({
        'eventId': eventId,
        'userId': user.uid,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully registered for the event!'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              event['title'] ?? 'No title',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              event['description'] ?? '',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 25),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(event['date'] ?? ''),
            ),

            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(event['time'] ?? ''),
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Venue'),
              subtitle: Text(event['venue'] ?? ''),
            ),

            ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('Organizer'),
              subtitle: Text(event['organizer'] ?? ''),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  registerForEvent(context);
                },
                child: const Text(
                  'Register for Event',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}