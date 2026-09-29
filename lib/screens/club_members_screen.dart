import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubMembersScreen extends StatelessWidget {
  final String clubId;
  final String clubName;

  const ClubMembersScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$clubName Members'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubMemberships')
            .where('clubId', isEqualTo: clubId)
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
                'No members yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final memberships = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: memberships.length,
            itemBuilder: (context, index) {
              final membership =
              memberships[index].data() as Map<String, dynamic>;

              final userId = membership['userId'];
              final domain = membership['domain'] ?? 'Not specified';
              final role = membership['role'] ?? 'Member';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),

                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  if (!userSnapshot.hasData ||
                      !userSnapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;

                  final name = userData['name'] ?? 'Unknown User';
                  final department =
                      userData['department'] ?? 'Department not available';
                  final semester =
                      userData['semester'] ?? 'Semester not available';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),

                      leading: const CircleAvatar(
                        radius: 28,
                        child: Icon(Icons.person),
                      ),

                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$department • Semester $semester'),
                            const SizedBox(height: 4),
                            Text('Domain: $domain'),
                            const SizedBox(height: 4),
                            Text('Role: ${role.toString().toUpperCase()}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}