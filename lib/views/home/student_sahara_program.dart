import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_student_screen.dart';

class StudentSaharaScreen extends StatelessWidget {
  const StudentSaharaScreen({super.key});

  String formatDate(Timestamp timestamp) =>
      DateFormat('dd MMM yyyy').format(timestamp.toDate());

  Future<void> deleteStudent(BuildContext ctx, String id) async {
    await FirebaseFirestore.instance.collection('requested_students').doc(id).delete();
    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Deleted')));
  }

  Future<int> _fetchCurrentBalance() async {
    final snap = await FirebaseFirestore.instance.collection('stats').doc('current').get();
    if (snap.exists) {
      return (snap.data()?['current_balance'] as num? ?? 0).toInt();
    }
    return 0;
  }

  Future<void> _updateBalance(int newBalance) =>
      FirebaseFirestore.instance.collection('stats').doc('current')
          .set({'current_balance': newBalance}, SetOptions(merge: true));

  Future<void> _moveToSupportedCollection(Map<String, dynamic> data, String docId, String status) async {
    data['status'] = status;
    data['granted_at'] = Timestamp.now();
    data['installments_paid'] = [];

    await FirebaseFirestore.instance.collection('supported_students').doc(docId).set(data);
    await FirebaseFirestore.instance.collection('requested_students').doc(docId).delete();
  }

  Future<void> _approveRequest(BuildContext ctx, Map<String, dynamic> data, String docId) async {
    final type = (data['type_of_support'] ?? '').toString().toLowerCase();
    final amount = (data['amount_requested'] as num? ?? 0).toInt();
    final currentBalance = await _fetchCurrentBalance();

    if (currentBalance < amount) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
      return;
    }

    if (type != 'loan') {
      showDialog(
        context: ctx,
        builder: (c) => AlertDialog(
          title: Text('${data['type_of_support']} Approval'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Support Type: ${data['type_of_support']}'),
              const SizedBox(height: 8),
              Text('Amount: Rs. $amount'),
              const SizedBox(height: 8),
              Text('Current Balance: Rs. $currentBalance'),
              if (currentBalance < amount)
                const Text('Insufficient balance', style: TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: currentBalance >= amount
                  ? () async {
                await _updateBalance(currentBalance - amount);
                await _moveToSupportedCollection(data, docId, 'granted');
                Navigator.pop(c);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Support granted')));
              }
                  : null,
              child: const Text('Grant Support'),
            ),
          ],
        ),
      );
    } else {
      int installments = 1;
      DateTime? selectedStartDate;

      showDialog(
        context: ctx,
        builder: (c) {
          return StatefulBuilder(
            builder: (c2, setState) {
              final perInstallment = (amount / installments).ceil();
              return AlertDialog(
                title: const Text('Loan Approval'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Requested: Rs. $amount'),
                    const SizedBox(height: 8),
                    Text('Current Balance: Rs. $currentBalance'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Installments:'),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: installments,
                          items: List.generate(24, (i) => i + 1)
                              .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                              .toList(),
                          onChanged: (v) => setState(() => installments = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Per Installment: Rs. $perInstallment'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedStartDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(selectedStartDate == null
                          ? 'Select First Installment Date'
                          : 'Start: ${DateFormat('dd MMM yyyy').format(selectedStartDate!)}'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c2), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: selectedStartDate != null
                        ? () async {
                      final endDate = DateTime(
                        selectedStartDate!.year,
                        selectedStartDate!.month + installments,
                        selectedStartDate!.day,
                      );

                      await _updateBalance(currentBalance - amount);

                      final loanData = {
                        'student_id': data['student_id'],
                        'full_name': data['full_name'],
                        'type_of_support': data['type_of_support'],
                        'amount': amount,
                        'installments': installments,
                        'per_installment': perInstallment,
                        'start_date': Timestamp.fromDate(selectedStartDate!),
                        'end_date': Timestamp.fromDate(endDate),
                        'granted_at': Timestamp.now(),
                        'installments_paid': [],
                        'status': 'active',
                      };

                      await FirebaseFirestore.instance.collection('active_loans').doc(docId).set(loanData);
                      await _moveToSupportedCollection(data, docId, 'loan_granted');

                      Navigator.pop(c2);
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Loan granted')));
                    }
                        : null,
                    child: const Text('Grant Loan'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Sahara Program'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen()));
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requested_students')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No requests yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(data['full_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                        Text("#${data['student_id']}", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(data['created_at'] != null ? formatDate(data['created_at']) : '', style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        Chip(
                          label: Text((data['status'] ?? 'requested').toString().toUpperCase()),
                          backgroundColor: Colors.deepPurple.shade50,
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        const Icon(Icons.volunteer_activism, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(data['type_of_support'] ?? '', style: const TextStyle(fontSize: 14)),
                      ]),
                      Text("Rs. ${data['amount_requested']}", style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: Colors.indigo), tooltip: 'Edit'),
                      IconButton(onPressed: () => deleteStudent(context, docId), icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Delete'),
                      IconButton(
                        onPressed: () => _approveRequest(context, data, docId),
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Approve',
                      ),
                    ]),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
