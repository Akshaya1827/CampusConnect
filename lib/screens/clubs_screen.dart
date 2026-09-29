import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'club_details_screen.dart';

class ClubsScreen extends StatelessWidget {
  const ClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clubs'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No clubs available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final clubs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clubs.length,

            itemBuilder: (context, index) {
              final club =
              clubs[index].data() as Map<String, dynamic>;

              final clubId = clubs[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),

                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.groups),
                  ),

                  title: Text(
                    club['name'] ?? 'No name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    club['category'] ?? '',
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubDetailsScreen(
                          club: club,
                          clubId: clubId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}