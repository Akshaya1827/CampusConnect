import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'events_screen.dart';
import 'clubs_screen.dart';
import 'coordinator_dashboard_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'my_application_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAnnouncements(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.announcement),
                    SizedBox(width: 10),
                    Text(
                      'Announcements',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('announcements')
                      .orderBy(
                    'createdAt',
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
                          'Error loading announcements:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final announcements =
                        snapshot.data?.docs ?? [];

                    if (announcements.isEmpty) {
                      return const Center(
                        child: Text(
                          'No announcements yet',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final announcement =
                        announcements[index];

                        final data =
                        announcement.data()
                        as Map<String, dynamic>;

                        final title =
                            data['title'] ?? 'Announcement';

                        final message =
                            data['message'] ?? '';

                        final timestamp =
                        data['createdAt'] as Timestamp?;

                        String dateText = '';

                        if (timestamp != null) {
                          final date = timestamp.toDate();

                          dateText =
                          '${date.day}/${date.month}/${date.year}';
                        }

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.campaign,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        title.toString(),
                                        style:
                                        const TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  message.toString(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                if (dateText.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    dateText,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Connect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const NotificationsScreen(),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            // =========================
            // GREETING
            // =========================
            const Text(
              'Good Morning! ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Welcome back to Campus Connect',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // COORDINATOR DASHBOARD
            // =========================
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(
                FirebaseAuth.instance.currentUser!.uid,
              )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const SizedBox();
                }

                final userData =
                snapshot.data!.data()
                as Map<String, dynamic>;

                final role = userData['role'];

                if (role != 'coordinator') {
                  return const SizedBox();
                }

                return Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const CoordinatorDashboardScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.admin_panel_settings,
                      ),
                      label: const Text(
                        'Coordinator Dashboard',
                      ),
                    ),
                  ),
                );
              },
            ),

            // =========================
            // SEARCH BAR
            // =========================
            TextField(
              decoration: InputDecoration(
                hintText:
                'Search events, clubs, announcements...',
                prefixIcon:
                const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // QUICK ACCESS
            // =========================
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.event,
                    title: 'Events',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const EventsScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _QuickAction(
                    icon: Icons.groups,
                    title: 'Clubs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const ClubsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.announcement,
                    title: 'Announcements',
                    onTap: () {
                      _showAnnouncements(context);
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _QuickAction(
                    icon: Icons.assignment,
                    title: 'My Applications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const MyApplicationsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // =========================
            // UPCOMING EVENTS
            // =========================
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _EventCard(
              title: 'Tech Fest 2026',
              date: '25 September 2026',
              venue: 'Main Auditorium',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const EventsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _EventCard(
              title: 'Coding Competition',
              date: '28 September 2026',
              venue: 'Computer Lab',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const EventsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // =========================
            // CAMPUS UPDATES
            // =========================
            const Text(
              'Campus Updates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _UpdateCard(
              icon: Icons.campaign,
              title: 'New Club Registration Open',
              subtitle:
              'Students can register for new clubs.',
              onTap: () {
                _showAnnouncements(context);
              },
            ),

            const SizedBox(height: 10),

            _UpdateCard(
              icon: Icons.info_outline,
              title: 'Important Announcement',
              subtitle:
              'Check the latest campus information.',
              onTap: () {
                _showAnnouncements(context);
              },
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          switch (index) {
            case 0:
            // Already on Home
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const EventsScreen(),
                ),
              );
              break;

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const ClubsScreen(),
                ),
              );
              break;

            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const ProfileScreen(),
                ),
              );
              break;
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


// =====================================================
// QUICK ACCESS CARD
// =====================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =====================================================
// EVENT CARD
// =====================================================

class _EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String venue;
  final VoidCallback onTap;

  const _EventCard({
    required this.title,
    required this.date,
    required this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(12),
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.event),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '$date\n$venue',
          ),
          isThreeLine: true,
          trailing: const Icon(
            Icons.arrow_forward_ios,
          ),
        ),
      ),
    );
  }
}


// =====================================================
// CAMPUS UPDATE CARD
// =====================================================

class _UpdateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UpdateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'events_screen.dart';
// import 'clubs_screen.dart';
// import 'coordinator_dashboard_screen.dart';
// import 'notifications_screen.dart';
// import 'profile_screen.dart';
// import 'my_application_screen.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   void _showAnnouncements(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return SizedBox(
//           height: MediaQuery.of(context).size.height * 0.75,
//           child: Column(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Icon(Icons.announcement),
//                     SizedBox(width: 10),
//                     Text(
//                       'Announcements',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1),
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('announcements')
//                       .orderBy('createdAt', descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }
//
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Text(
//                           'Error loading announcements:\n${snapshot.error}',
//                           textAlign: TextAlign.center,
//                         ),
//                       );
//                     }
//
//                     final announcements =
//                         snapshot.data?.docs ?? [];
//
//                     if (announcements.isEmpty) {
//                       return const Center(
//                         child: Text(
//                           'No announcements yet',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       );
//                     }
//
//                     return ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: announcements.length,
//                       itemBuilder: (context, index) {
//                         final announcement =
//                         announcements[index];
//
//                         final data =
//                         announcement.data()
//                         as Map<String, dynamic>;
//
//                         final title =
//                             data['title'] ?? 'Announcement';
//
//                         final message =
//                             data['message'] ?? '';
//
//                         final timestamp =
//                         data['createdAt'] as Timestamp?;
//
//                         String dateText = '';
//
//                         if (timestamp != null) {
//                           final date = timestamp.toDate();
//
//                           dateText =
//                           '${date.day}/${date.month}/${date.year}';
//                         }
//
//                         return Card(
//                           margin: const EdgeInsets.only(
//                             bottom: 12,
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                                   children: [
//                                     const Icon(
//                                       Icons.campaign,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: Text(
//                                         title.toString(),
//                                         style:
//                                         const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight:
//                                           FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Text(
//                                   message.toString(),
//                                   style: const TextStyle(
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                                 if (dateText.isNotEmpty) ...[
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     dateText,
//                                     style: const TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Campus Connect'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const NotificationsScreen(),
//                 ),
//               );
//             },
//           ),
//           const Padding(
//             padding: EdgeInsets.only(right: 12),
//             child: CircleAvatar(
//               child: Icon(Icons.person),
//             ),
//           ),
//         ],
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             // Greeting
//             const Text(
//               'Good Morning! ',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 6),
//
//             const Text(
//               'Welcome back to Campus Connect',
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey,
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(FirebaseAuth.instance.currentUser!.uid)
//                   .get(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData ||
//                     !snapshot.data!.exists) {
//                   return const SizedBox();
//                 }
//
//                 final userData =
//                 snapshot.data!.data()
//                 as Map<String, dynamic>;
//
//                 final role = userData['role'];
//
//                 if (role != 'coordinator') {
//                   return const SizedBox();
//                 }
//
//                 return Padding(
//                   padding:
//                   const EdgeInsets.symmetric(vertical: 10),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                             const CoordinatorDashboardScreen(),
//                           ),
//                         );
//                       },
//                       icon: const Icon(
//                         Icons.admin_panel_settings,
//                       ),
//                       label: const Text(
//                         'Coordinator Dashboard',
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             // Search bar
//             TextField(
//               decoration: InputDecoration(
//                 hintText:
//                 'Search events, clubs, announcements...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 25),
//
//             // Quick Access
//             const Text(
//               'Quick Access',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _QuickAction(
//                     icon: Icons.event,
//                     title: 'Events',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                           const EventsScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//
//                 Expanded(
//                   child: _QuickAction(
//                     icon: Icons.groups,
//                     title: 'Clubs',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                           const ClubsScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _QuickAction(
//                     icon: Icons.announcement,
//                     title: 'Announcements',
//                     onTap: () {
//                       _showAnnouncements(context);
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//
//                 Expanded(
//                   child: _QuickAction(
//                     icon: Icons.assignment,
//                     title: 'My Applications',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                           const MyApplicationsScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _QuickAction(
//                     icon: Icons.person,
//                     title: 'Profile',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                           const ProfileScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 28),
//
//             // Upcoming Events
//             const Text(
//               'Upcoming Events',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             _EventCard(
//               title: 'Tech Fest 2026',
//               date: '25 September 2026',
//               venue: 'Main Auditorium',
//             ),
//
//             const SizedBox(height: 12),
//
//             _EventCard(
//               title: 'Coding Competition',
//               date: '28 September 2026',
//               venue: 'Computer Lab',
//             ),
//
//             const SizedBox(height: 28),
//
//             // Campus Updates
//             const Text(
//               'Campus Updates',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             _UpdateCard(
//               icon: Icons.campaign,
//               title: 'New Club Registration Open',
//               subtitle:
//               'Students can register for new clubs.',
//             ),
//
//             const SizedBox(height: 10),
//
//             _UpdateCard(
//               icon: Icons.info_outline,
//               title: 'Important Announcement',
//               subtitle:
//               'Check the latest campus information.',
//             ),
//           ],
//         ),
//       ),
//
//       // Bottom Navigation
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.event),
//             label: 'Events',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.groups),
//             label: 'Clubs',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// // Quick Access Card
// class _QuickAction extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;
//
//   const _QuickAction({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             vertical: 20,
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 icon,
//                 size: 32,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// // Event Card
// class _EventCard extends StatelessWidget {
//   final String title;
//   final String date;
//   final String venue;
//
//   const _EventCard({
//     required this.title,
//     required this.date,
//     required this.venue,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: const CircleAvatar(
//           child: Icon(Icons.event),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         subtitle: Text('$date\n$venue'),
//         isThreeLine: true,
//         trailing: const Icon(
//           Icons.arrow_forward_ios,
//         ),
//       ),
//     );
//   }
// }
//
//
// // Campus Update Card
// class _UpdateCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//
//   const _UpdateCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: Icon(icon),
//         title: Text(
//           title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         subtitle: Text(subtitle),
//       ),
//     );
//   }
//}