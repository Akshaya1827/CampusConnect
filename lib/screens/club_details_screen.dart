import 'package:flutter/material.dart';
import 'club_application_screen.dart';
import 'club_members_screen.dart';
class ClubDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> club;
  final String clubId;

  const ClubDetailsScreen({
    super.key,
    required this.club,
    required this.clubId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Club name
            Text(
              club['name'] ?? 'No name',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Category
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Category'),
              subtitle: Text(
                club['category'] ?? '',
              ),
            ),

            // Description
            const SizedBox(height: 10),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              club['description'] ?? '',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 30),

            // Join button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClubApplicationScreen(
                        club: club,
                        clubId: clubId,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Apply to Join',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClubMembersScreen(
                        clubId: clubId,
                        clubName: club['name'] ?? 'Club',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.groups),
                label: const Text('View Club Members'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}