import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final studentIdController = TextEditingController();
  final fullNameController = TextEditingController();
  final guardianNameController = TextEditingController();
  final classGradeController = TextEditingController();
  final institutionController = TextEditingController();
  final cityController = TextEditingController();
  final requestedDateController = TextEditingController();
  final amountController = TextEditingController();
  final remarksController = TextEditingController();

  String? selectedGender;
  String? selectedProvince;
  String? selectedSupportType;

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      requestedDateController.text = pickedDate.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final studentId = studentIdController.text.trim();

    final existing = await FirebaseFirestore.instance
        .collection('requested_students')
        .doc(studentId)
        .get();

    if (existing.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student with this ID already exists!')),
      );
      return;
    }

    final supportType = selectedSupportType?.toLowerCase() ?? '';
    final isLoan = selectedSupportType == 'Loan';

    final studentData = {
      'student_id': studentId,
      'full_name': fullNameController.text.trim(),
      'guardian_name': guardianNameController.text.trim(),
      'gender': selectedGender,
      'class_grade': classGradeController.text.trim(),
      'institution_name': institutionController.text.trim(),
      'city': cityController.text.trim(),
      'province': selectedProvince,
      'type_of_support': selectedSupportType,
      'requested_date': requestedDateController.text,
      'amount_requested': int.tryParse(amountController.text.trim()) ?? 0,
      'remarks': remarksController.text.trim(),
      'status': 'requested',
      'created_at': Timestamp.now(),
    };

    try {
      // Insert request to Firestore
      await FirebaseFirestore.instance
          .collection('requested_students')
          .doc(studentId)
          .set(studentData);

      // Update stats counter
      final statKey = isLoan ? 'request_for_loan' : 'request_for_support';
      final statRef = FirebaseFirestore.instance.collection('stats').doc('request_counters');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(statRef);

        if (snapshot.exists) {
          final currentValue = snapshot.data()?[statKey] ?? 0;
          transaction.update(statRef, {statKey: currentValue + 1});
        } else {
          transaction.set(statRef, {statKey: 1});
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student request added successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student Request"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Wrap(
            runSpacing: 16,
            children: [
              TextFormField(
                controller: studentIdController,
                decoration: _inputDecoration("Student ID"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fullNameController,
                      decoration: _inputDecoration("Full Name"),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: _inputDecoration("Gender"),
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedGender = val),
                      validator: (val) => val == null ? "Required" : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: guardianNameController,
                decoration: _inputDecoration("Guardian Name"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: classGradeController,
                      decoration: _inputDecoration("Class Grade"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: institutionController,
                      decoration: _inputDecoration("Institution"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: cityController,
                decoration: _inputDecoration("City"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedProvince,
                decoration: _inputDecoration("Province"),
                items: ['Punjab', 'Sindh', 'KPK', 'Balochistan', 'GB', 'ICT']
                    .map((prov) => DropdownMenuItem(value: prov, child: Text(prov)))
                    .toList(),
                onChanged: (val) => setState(() => selectedProvince = val),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedSupportType,
                decoration: _inputDecoration("Type of Support"),
                items: ['Loan', 'Scholarship', 'Fees', 'Uniform', 'Others']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => selectedSupportType = val),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: requestedDateController,
                readOnly: true,
                onTap: pickDate,
                decoration: _inputDecoration("Requested Date").copyWith(
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: amountController,
                decoration: _inputDecoration("Amount Requested"),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: remarksController,
                decoration: _inputDecoration("Remarks"),
                maxLines: 2,
              ),

              // Commented image & document upload
              /*
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.image),
                      label: const Text("Upload Image"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.insert_drive_file),
                      label: const Text("Upload Document"),
                    ),
                  ),
                ],
              ),
              */

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: addStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Center(child: Text("Add Request", style: TextStyle(fontSize: 18))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
