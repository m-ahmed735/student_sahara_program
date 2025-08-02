import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_sahara_program/views/home/student_sahara_program.dart';
import 'package:student_sahara_program/views/loans/loan_list_screen.dart';

import 'donations_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('stats').doc('current').snapshots(),
              builder: (context, snapshot) {
                int currentBalance = 0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  currentBalance = data['current_balance'] ?? 0;
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D5DF6), Color(0xFF8D58BF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs. $currentBalance',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.white70, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'After support distribution',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Summary Cards in Grid (3 per row)
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1,
              children: [
                // Total Donations
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('donations').get(),
                  builder: (context, snapshot) {
                    int totalDonations = 0;
                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final amount = data['amount'] as num? ?? 0;
                        totalDonations += amount.toInt();
                      }
                    }
                    return _DashboardCard(
                      title: 'Total Donations',
                      value: 'Rs. $totalDonations',
                      icon: Icons.volunteer_activism,
                    );
                  },
                ),

                // Students Supported
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('supported_students').get(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return _DashboardCard(
                      title: 'Students Supported',
                      value: '$count',
                      icon: Icons.group,
                    );
                  },
                ),

                // Pending Requests
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('requested_students')
                      .where('status', isEqualTo: 'requested')
                      .get(),
                  builder: (context, snapshot) {
                    int pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return _DashboardCard(
                      title: 'Pending Requests',
                      value: '$pendingCount',
                      icon: Icons.pending_actions_rounded,
                    );
                  },
                ),

                // Active Loans
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('active_loans').get(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return _DashboardCard(
                      title: 'Active Loans',
                      value: '$count',
                      icon: Icons.money_rounded,
                    );
                  },
                ),

                // Loans Provided
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('provided_loans').get(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return _DashboardCard(
                      title: 'Loans Provided',
                      value: '$count',
                      icon: Icons.check_circle_outline,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _programCard(
              context,
              title: 'Requests',
              icon: Icons.volunteer_activism,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentSaharaScreen()),
                );
              },
            ),
            const SizedBox(height: 8),

            _programCard(
              context,
              title: 'Active Loans',
              icon: Icons.money_rounded,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActiveLoansScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _programCard(
              context,
              title: 'Provided Loans',
              icon: Icons.assignment_turned_in_outlined,
              color: Colors.teal,
              onTap: () {
                // TODO: Implement ProvidedLoansScreen
              },
            ),

            const SizedBox(height: 8),

            _programCard(
              context,
              title: 'Supported Students',
              icon: Icons.people_outline,
              color: Colors.orange,
              onTap: () {
                // TODO: Implement SupportedStudentsScreen
              },
            ),

            const SizedBox(height: 8),

            _programCard(
              context,
              title: 'Manage Donations',
              icon: Icons.card_giftcard_rounded,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonationsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _programCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox( // ✅ Prevents overflow completely
      child: Container(
        width: 110, // Keep consistent width
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFe3f2fd),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

