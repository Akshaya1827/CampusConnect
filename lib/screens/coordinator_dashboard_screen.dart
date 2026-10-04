import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
class CoordinatorDashboardScreen extends StatelessWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Create Announcement',
            onPressed: () {
              _createAnnouncement(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('clubs')
            .where(
          'coordinatorId',
          isEqualTo: currentUser.uid,
        )
            .limit(1)
            .get(),

        builder: (context, clubSnapshot) {
          if (clubSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (clubSnapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${clubSnapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!clubSnapshot.hasData ||
              clubSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No club assigned to this coordinator.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          final clubDocument = clubSnapshot.data!.docs.first;
          final clubId = clubDocument.id;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('clubApplications')
                .where(
              'clubId',
              isEqualTo: clubId,
            )
                .orderBy(
              'appliedAt',
              descending: true,
            )
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No applications received yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              final applications = snapshot.data!.docs;

              int applied = 0;
              int shortlisted = 0;
              int interview = 0;
              int selected = 0;
              int rejected = 0;

              for (final doc in applications) {
                final data =
                doc.data() as Map<String, dynamic>;

                final status = data['status'] ?? 'applied';

                switch (status) {
                  case 'applied':
                    applied++;
                    break;

                  case 'shortlisted':
                    shortlisted++;
                    break;

                  case 'interview':
                    interview++;
                    break;

                  case 'selected':
                    selected++;
                    break;

                  case 'rejected':
                    rejected++;
                    break;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Application Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: Row(
                        children: [
                          _statCard(
                            'Total',
                            applications.length,
                            Icons.people,
                          ),

                          _statCard(
                            'Applied',
                            applied,
                            Icons.assignment,
                          ),

                          _statCard(
                            'Shortlisted',
                            shortlisted,
                            Icons.star,
                          ),

                          _statCard(
                            'Interview',
                            interview,
                            Icons.groups,
                          ),

                          _statCard(
                            'Selected',
                            selected,
                            Icons.check_circle,
                          ),

                          _statCard(
                            'Rejected',
                            rejected,
                            Icons.cancel,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Applications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: applications.length,

                      itemBuilder: (context, index) {
                        final document = applications[index];

                        final application =
                        document.data()
                        as Map<String, dynamic>;

                        return _applicationCard(
                          context,
                          application,
                          document.id,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statCard(
      String title,
      int count,
      IconData icon,
      ) {
    return Container(
      width: 130,
      height: 125,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget _applicationCard(
      BuildContext context,
      Map<String, dynamic> application,
      String applicationId,
      ) {
    final name = application['name'] ?? 'Unknown';
    final department = application['department'] ?? '';
    final semester = application['semester'] ?? '';
    final domain = application['preferredDomain'] ?? '';
    final status = application['status'] ?? 'applied';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '$department • Semester $semester\n'
                'Domain: $domain\n'
                'Status: ${status.toUpperCase()}',
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),

        onTap: () {
          _showApplicationDetails(
            context,
            application,
            applicationId,
          );
        },
      ),
    );
  }
  Future<void> _createAnnouncement(BuildContext context) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final message = messageController.text.trim();

                if (title.isEmpty || message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in both fields'),
                    ),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    throw Exception('User not logged in');
                  }

                  await FirebaseFirestore.instance
                      .collection('announcements')
                      .add({
                    'title': title,
                    'message': message,
                    'createdBy': user.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (!context.mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Announcement published successfully!',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to publish announcement: $e',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Publish'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    messageController.dispose();
  }
  Future<void> _updateApplicationStatus(
      BuildContext context,
      String applicationId,
      String status,
      ) async {
    try {
      // Get application data first
      final applicationSnapshot = await FirebaseFirestore.instance
          .collection('clubApplications')
          .doc(applicationId)
          .get();

      if (!applicationSnapshot.exists) {
        throw Exception('Application not found');
      }

      final application =
      applicationSnapshot.data() as Map<String, dynamic>;

      final userId = application['userId'];

      if (userId == null || userId.toString().isEmpty) {
        throw Exception('Applicant user ID not found');
      }

      // Update application status
      await FirebaseFirestore.instance
          .collection('clubApplications')
          .doc(applicationId)
          .update({
        'status': status,
      });

      // Create notification for the applicant
      String title;
      String message;

      if (status == 'shortlisted') {
        title = 'Application Shortlisted';
        message =
        'Your club application has been shortlisted. Please wait for further interview details.';
      } else if (status == 'rejected') {
        title = 'Application Update';
        message =
        'Your club application has been rejected. Thank you for your interest.';
      } else {
        title = 'Application Update';
        message = 'Your club application status is now: $status';
      }

      await NotificationService.createNotification(
        userId: userId.toString(),
        title: title,
        message: message,
        type: 'application',
      );

      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'shortlisted'
                ? 'Application shortlisted and applicant notified!'
                : status == 'rejected'
                ? 'Application rejected and applicant notified!'
                : 'Application status updated!',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update application: $e'),
        ),
      );
    }
  }
  void _showApplicationDetails(
      BuildContext context,
      Map<String, dynamic> application,
      String applicationId,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Application Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _detail('Name', application['name']),
                _detail('Email', application['email']),
                _detail('Phone', application['phone']),
                _detail('Department', application['department']),
                _detail('Semester', application['semester']),
                _detail('Skills', application['skills']),
                _detail('Why Join', application['reason']),
                _detail(
                  'Preferred Domain',
                  application['preferredDomain'],
                ),
                _detail(
                  'Status',
                  application['status'],
                ),

                const SizedBox(height: 20),

                // SHORTLIST BUTTON
                if (application['status'] == 'applied')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.star),
                      label: const Text('Shortlist'),
                      onPressed: () {
                        _updateApplicationStatus(
                          context,
                          applicationId,
                          'shortlisted',
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // REJECT BUTTON
                if (application['status'] == 'applied')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      onPressed: () {
                        _updateApplicationStatus(
                          context,
                          applicationId,
                          'rejected',
                        );
                      },
                    ),
                  ),
                if (application['status'] == 'shortlisted')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Schedule Interview'),
                      onPressed: () {
                        _scheduleInterview(
                          context,
                          applicationId,
                        );
                      },
                    ),
                  ),
                if (application['status'] == 'interview')
                  const SizedBox(height: 10),

                if (application['status'] == 'interview')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Select Candidate'),
                      onPressed: () {
                        _selectCandidate(
                          context,
                          applicationId,
                          application,
                        );
                      },
                    ),
                  ),

                if (application['status'] == 'interview')
                  const SizedBox(height: 10),

                if (application['status'] == 'interview')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject Candidate'),
                      onPressed: () {
                        _updateApplicationStatus(
                          context,
                          applicationId,
                          'rejected',
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 10),

                // CLOSE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scheduleInterview(
      BuildContext context,
      String applicationId,
      ) async {
    // Select interview date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (selectedDate == null) return;

    if (!context.mounted) return;

    // Select interview time
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    if (!context.mounted) return;

    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Interview Details'),

          content: TextField(
            controller: notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Interview Notes',
              hintText: 'Enter interview instructions or notes',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('clubApplications')
                      .doc(applicationId)
                      .update({
                    // Change application status
                    'status': 'interview',

                    // Save interview date
                    'interviewDate': Timestamp.fromDate(selectedDate),

                    // Save interview time
                    'interviewTime':
                    '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',

                    // Save interview notes
                    'interviewNotes':
                    notesController.text.trim(),
                  });

                  if (!context.mounted) return;

                  Navigator.pop(dialogContext);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Interview scheduled successfully!',
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to schedule interview: $e',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Schedule'),
            ),
          ],
        );
      },
    );

    notesController.dispose();
  }
  Future<void> _selectCandidate(
      BuildContext context,
      String applicationId,
      Map<String, dynamic> application,
      ) async {
    try {
      final clubId = application['clubId'];
      final userId = application['userId'];
      final preferredDomain = application['preferredDomain'];

      if (clubId == null || userId == null) {
        throw Exception('Club ID or User ID is missing');
      }

      // Check whether the student is already a member
      final existingMembership = await FirebaseFirestore.instance
          .collection('clubMemberships')
          .where('clubId', isEqualTo: clubId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      // Create membership only if one doesn't already exist
      if (existingMembership.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('clubMemberships')
            .add({
          'clubId': clubId,
          'userId': userId,
          'domain': preferredDomain,
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }

      // Update application status
      await FirebaseFirestore.instance
          .collection('clubApplications')
          .doc(applicationId)
          .update({
        'status': 'selected',
        'interviewResult': 'selected',
      });

      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Candidate selected and added as club member!',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select candidate: $e',
          ),
        ),
      );
    }
  }
  Widget _detail(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value?.toString() ?? 'Not provided',
          ),
        ],
      ),
    );
  }
}