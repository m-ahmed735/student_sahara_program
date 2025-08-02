import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donations List"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddDonationDialog());
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No donations yet."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final String name = data['name'] ?? 'N/A';
              final String type = data['type_of_donation'] ?? 'N/A';
              final String contact = data['contact_number'] ?? 'N/A';
              final int amount = data['amount'] ?? 0;
              final Timestamp? timestamp = data['created_at'];
              final String formattedDate = timestamp != null
                  ? DateFormat('dd MMM yyyy').format(timestamp.toDate())
                  : 'Unknown Date';

              return GestureDetector(
                onTap: () {
                  // Future: open detail view
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Icon(Icons.volunteer_activism, color: Colors.deepPurple.shade700),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87)),
                              const SizedBox(height: 6),
                              Text("Contact: $contact",
                                  style: const TextStyle(color: Colors.black54, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text("Type: $type",
                                  style: const TextStyle(color: Colors.black87, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text("Amount: Rs. $amount",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text("Date: $formattedDate",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
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
class AddDonationDialog extends StatefulWidget {
  const AddDonationDialog({super.key});

  @override
  State<AddDonationDialog> createState() => _AddDonationDialogState();
}

class _AddDonationDialogState extends State<AddDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final professionController = TextEditingController();
  final amountController = TextEditingController();
  final contactController = TextEditingController();
  String? donationType;

  Future<void> addDonation() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final amount = int.tryParse(amountController.text.trim()) ?? 0;

      final data = {
        'name': nameController.text.trim(),
        'donor_id': idController.text.trim(),
        'profession': professionController.text.trim(),
        'amount': amount,
        'type_of_donation': donationType,
        'contact_number': contactController.text.trim(),
        'created_at': Timestamp.now(),
      };

      // Add donation to donations collection
      await FirebaseFirestore.instance.collection('donations').add(data);

      // Reference to stats/current document
      final statsRef = FirebaseFirestore.instance.collection('stats').doc('current');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);

        if (snapshot.exists) {
          final currentBalance = snapshot.get('current_balance') ?? 0;
          transaction.update(statsRef, {
            'current_balance': currentBalance + amount,
          });
        } else {
          transaction.set(statsRef, {
            'current_balance': amount,
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation added successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Donation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration("Donor Name"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: idController,
                decoration: _inputDecoration("Donor ID"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: professionController,
                decoration: _inputDecoration("Profession"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                decoration: _inputDecoration("Amount Donated"),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Type of Donation"),
                value: donationType,
                items: ["Loan", "Scholarship", "Fees", "Uniform", "Other"]
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => donationType = val),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contactController,
                decoration: _inputDecoration("Contact Number"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Center(child: Text("Add Donation", style: TextStyle(fontSize: 16))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
