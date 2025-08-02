import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveLoansScreen extends StatelessWidget {
  const ActiveLoansScreen({super.key});

  String formatDate(Timestamp timestamp) =>
      DateFormat('dd MMM yyyy').format(timestamp.toDate());

  Future<int> _fetchCurrentBalance() async {
    final snap = await FirebaseFirestore.instance.collection('stats').doc('current').get();
    if (snap.exists) {
      return (snap.data()?['current_balance'] as num? ?? 0).toInt();
    }
    return 0;
  }

  Future<void> _updateBalance(int newBalance) {
    return FirebaseFirestore.instance
        .collection('stats')
        .doc('current')
        .set({'current_balance': newBalance}, SetOptions(merge: true));
  }

  Future<void> _payInstallment(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;

    final int totalInstallments = data['installments'];
    final int perInstallment = data['per_installment'];
    final int amount = data['amount'];
    final List<dynamic> paidInstallments = List.from(data['installments_paid'] ?? []);
    final int paidCount = paidInstallments.length;
    final int nextInstallment = paidCount + 1;

    if (nextInstallment > totalInstallments) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All installments already paid.')),
      );
      return;
    }

    final currentDate = DateTime.now();
    final newInstallment = {
      'installment_no': nextInstallment,
      'amount': perInstallment,
      'date': Timestamp.fromDate(currentDate),
    };

    final updatedInstallments = [...paidInstallments, newInstallment];
    final newBalance = await _fetchCurrentBalance() + perInstallment;

    await FirebaseFirestore.instance.runTransaction((txn) async {
      final ref = FirebaseFirestore.instance;

      // Update current balance
      txn.set(ref.collection('stats').doc('current'), {
        'current_balance': newBalance,
      }, SetOptions(merge: true));

      if (updatedInstallments.length >= totalInstallments) {
        // Loan fully paid, move to provided_loans and delete from active_loans
        txn.set(ref.collection('provided_loans').doc(docId), {
          ...data,
          'installments_paid': updatedInstallments,
          'completed_at': Timestamp.fromDate(currentDate),
          'status': 'completed',
        });

        txn.delete(ref.collection('active_loans').doc(docId));
      } else {
        // Update the installments_paid field only
        txn.update(ref.collection('active_loans').doc(docId), {
          'installments_paid': updatedInstallments,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Installment paid successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Loans"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('active_loans').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No active loans found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String fullName = data['full_name'] ?? '';
              final String studentId = data['student_id'] ?? '';
              final int amount = data['amount'] ?? 0;
              final int installments = data['installments'] ?? 0;
              final int perInstall = data['per_installment'] ?? 0;
              final List<dynamic> paid = List.from(data['installments_paid'] ?? []);
              final int paidCount = paid.length;

              final Timestamp? startDate = data['start_date'];
              final Timestamp? endDate = data['end_date'];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          Text("#$studentId", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Loan: Rs. $amount"),
                          Text("Installments: $installments"),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Per Installment: Rs. $perInstall"),
                          Text("Paid: $paidCount / $installments"),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Start: ${startDate != null ? formatDate(startDate) : 'N/A'}"),
                          Text("Due: ${endDate != null ? formatDate(endDate) : 'N/A'}"),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _payInstallment(context, doc),
                          icon: const Icon(Icons.payments),
                          label: const Text("Pay Installment"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      )
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
