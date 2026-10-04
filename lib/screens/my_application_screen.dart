import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'shortlisted':
        return Colors.orange;
      case 'interview':
        return Colors.blue;
      case 'selected':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'shortlisted':
        return 'Shortlisted';
      case 'interview':
        return 'Interview';
      case 'selected':
        return 'Selected';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Applied';
    }
  }

  String _formatInterviewDate(dynamic date) {
    if (date == null) {
      return 'Date not available';
    }

    if (date is Timestamp) {
      final formattedDate = date.toDate();

      return '${formattedDate.day.toString().padLeft(2, '0')}/'
          '${formattedDate.month.toString().padLeft(2, '0')}/'
          '${formattedDate.year}';
    }

    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubApplications')
            .where(
          'userId',
          isEqualTo: user.uid,
        )
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

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have not applied to any club yet.',
                style: TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
            );
          }

          final applications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application =
              applications[index].data() as Map<String, dynamic>;

              final status =
                  application['status'] ?? 'applied';

              final clubId =
              application['clubId'];

              final domain =
                  application['preferredDomain'] ??
                      'Not specified';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // Club Name
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('clubs')
                            .doc(clubId)
                            .get(),
                        builder: (context, clubSnapshot) {
                          String clubName = 'Club';

                          if (clubSnapshot.hasData &&
                              clubSnapshot.data!.exists) {
                            final clubData =
                            clubSnapshot.data!.data()
                            as Map<String, dynamic>;

                            clubName =
                                clubData['name'] ?? 'Club';
                          }

                          return Text(
                            clubName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Preferred Domain
                      Text(
                        'Preferred Domain: $domain',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Status
                      Row(
                        children: [
                          const Text(
                            'Status: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status)
                                  .withOpacity(0.15),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusText(status),
                              style: TextStyle(
                                color:
                                _statusColor(status),
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Interview Details
                      if (status == 'interview') ...[
                        const SizedBox(height: 15),

                        const Divider(),

                        const SizedBox(height: 8),

                        const Text(
                          'Interview Scheduled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Date: ${_formatInterviewDate(application['interviewDate'])}',
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Time: ${application['interviewTime'] ?? 'Time not available'}',
                        ),

                        if (application['interviewNotes'] !=
                            null &&
                            application['interviewNotes']
                                .toString()
                                .isNotEmpty) ...[
                          const SizedBox(height: 8),

                          const Text(
                            'Notes:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            application['interviewNotes']
                                .toString(),
                          ),
                        ],
                      ],
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