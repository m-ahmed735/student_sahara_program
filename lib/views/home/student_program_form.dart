import 'package:flutter/material.dart';

class StudentSaharaForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Sahara Program')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Class'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Institution'),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Type of Request'),
                items: [
                  DropdownMenuItem(value: 'Scholarship', child: Text('Scholarship')),
                  DropdownMenuItem(value: 'Loan', child: Text('Loan')),
                ],
                onChanged: (value) {},
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Region'),
              ),
              DatePickerFormField(label: 'Date of Application'),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Save data
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DatePickerFormField extends StatelessWidget {
  final String label;

  DatePickerFormField({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          // Set date value
        }
      },
    );
  }
}
