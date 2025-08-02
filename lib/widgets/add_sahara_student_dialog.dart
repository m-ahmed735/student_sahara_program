import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

void showAddStudentDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final studentIdController = TextEditingController();
  final fullNameController = TextEditingController();
  final guardianNameController = TextEditingController();
  final classGradeController = TextEditingController();
  final institutionNameController = TextEditingController();
  final cityController = TextEditingController();
  final typeOfSupportController = TextEditingController();
  final durationMonthsController = TextEditingController();
  final amountSupportedController = TextEditingController();
  final remarksController = TextEditingController();
  final addedByAdminController = TextEditingController();

  String? gender, province, status;
  DateTime? supportStartDate;
  String? photoUrl, documentUrl;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final ref = FirebaseStorage.instance.ref('photos/${picked.name}');
      await ref.putFile(File(picked.path));
      photoUrl = await ref.getDownloadURL();
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final picked = File(result.files.single.path!);
      final ref = FirebaseStorage.instance.ref('documents/${result.files.single.name}');
      await ref.putFile(picked);
      documentUrl = await ref.getDownloadURL();
    }
  }

  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text('Add New Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  buildTextField("Student ID", studentIdController),
                  buildTextField("Full Name", fullNameController),
                  buildTextField("Guardian Name", guardianNameController),

                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(labelText: "Gender"),
                    items: ['Male', 'Female', 'Other'].map((e) =>
                        DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => gender = val,
                    validator: (val) => val == null ? 'Please select gender' : null,
                  ),

                  buildTextField("Class Grade", classGradeController),
                  buildTextField("Institution Name", institutionNameController),
                  buildTextField("City", cityController),

                  DropdownButtonFormField<String>(
                    value: province,
                    decoration: const InputDecoration(labelText: "Province"),
                    items: ['Punjab', 'Sindh', 'KPK', 'Balochistan', 'GB'].map((e) =>
                        DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => province = val,
                    validator: (val) => val == null ? 'Please select province' : null,
                  ),

                  buildTextField("Type of Support", typeOfSupportController),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(supportStartDate == null
                            ? 'Select Support Start Date'
                            : 'Date: ${supportStartDate.toString().split(' ')[0]}'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) supportStartDate = picked;
                        },
                        child: const Text("Pick Date"),
                      ),
                    ],
                  ),

                  buildTextField("Duration in Months", durationMonthsController, isNumber: true),
                  buildTextField("Amount Supported", amountSupportedController, isNumber: true),
                  buildTextField("Remarks", remarksController),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Text(photoUrl == null ? 'No Image Uploaded' : 'Image Uploaded')),
                      ElevatedButton(onPressed: pickImage, child: const Text("Upload Photo"))
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(child: Text(documentUrl == null ? 'No Doc Uploaded' : 'Doc Uploaded')),
                      ElevatedButton(onPressed: pickDocument, child: const Text("Upload Document"))
                    ],
                  ),

                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: "Status"),
                    items: ['Active', 'Completed', 'Dropped'].map((e) =>
                        DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => status = val,
                    validator: (val) => val == null ? 'Please select status' : null,
                  ),

                  buildTextField("Added by Admin", addedByAdminController),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && supportStartDate != null) {
                        final docRef = FirebaseFirestore.instance
                            .collection('supported_students')
                            .doc(studentIdController.text.trim());

                        final exists = await docRef.get();
                        if (exists.exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Student ID already exists")),
                          );
                          return;
                        }

                        await docRef.set({
                          'student_id': studentIdController.text.trim(),
                          'full_name': fullNameController.text.trim(),
                          'guardian_name': guardianNameController.text.trim(),
                          'gender': gender,
                          'class_grade': classGradeController.text.trim(),
                          'institution_name': institutionNameController.text.trim(),
                          'city': cityController.text.trim(),
                          'province': province,
                          'type_of_support': typeOfSupportController.text.trim(),
                          'support_start_date': supportStartDate!.toIso8601String(),
                          'duration_months': int.parse(durationMonthsController.text.trim()),
                          'amount_supported': int.parse(amountSupportedController.text.trim()),
                          'remarks': remarksController.text.trim(),
                          'photo_url': photoUrl ?? '',
                          'document_url': documentUrl ?? '',
                          'status': status,
                          'created_at': FieldValue.serverTimestamp(),
                          'added_by_admin': addedByAdminController.text.trim(),
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Student added successfully")),
                        );
                      }
                    },
                    child: const Text("Add Student"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    ),
  );
}

