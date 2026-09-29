import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  final String clubId;

  const ClubApplicationScreen({
    super.key,
    required this.club,
    required this.clubId,
  });

  @override
  State<ClubApplicationScreen> createState() =>
      _ClubApplicationScreenState();
}

class _ClubApplicationScreenState
    extends State<ClubApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final departmentController = TextEditingController();
  final semesterController = TextEditingController();
  final skillsController = TextEditingController();
  final reasonController = TextEditingController();

  String? selectedDomain;
  bool isSubmitting = false;

  final List<String> domains = [
    'Development',
    'Design',
    'Marketing',
    'Content',
    'Management',
    'Sponsorship',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    semesterController.dispose();
    skillsController.dispose();
    reasonController.dispose();

    super.dispose();
  }

  Future<void> submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDomain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a preferred domain'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('clubApplications')
          .add({
        'clubId': widget.clubId,
        'userId': user.uid,

        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'department': departmentController.text.trim(),
        'semester': semesterController.text.trim(),
        'skills': skillsController.text.trim(),
        'reason': reasonController.text.trim(),

        'preferredDomain': selectedDomain,
        'status': 'applied',

        'appliedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit application: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apply for ${widget.club['name'] ?? 'Club'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Fill in the details below to apply for this club.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              // Full Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Phone
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Department
              TextFormField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your department';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Semester
              TextFormField(
                controller: semesterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your semester';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Skills
              TextFormField(
                controller: skillsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  hintText: 'Example: Flutter, C++, Firebase',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your skills';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Why join
              TextFormField(
                controller: reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Why do you want to join this club?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Preferred Domain',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedDomain,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                hint: const Text('Select a domain'),
                items: domains.map((domain) {
                  return DropdownMenuItem(
                    value: domain,
                    child: Text(domain),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDomain = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : submitApplication,
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                    'Submit Application',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}