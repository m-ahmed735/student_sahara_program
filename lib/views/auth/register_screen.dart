import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  bool _obscurePassword = true;

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String city = _cityController.text.trim();
      String whatsapp = _whatsappController.text.trim();

      String dob = "01-01-2000"; // Or let user input this in form
      String userType = "admin"; // Can be a dropdown too

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.signUp(email, password, name, city, dob, whatsapp, userType);

      if (authProvider.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully")),
        );
        Navigator.pushReplacementNamed(context, '/login'); // or wherever you want to go after registration
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed. Please try again.")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // Spacing from top
              Center(
                child: Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,

                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  "Join Student Sahara today!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Full Name Field
              _buildInputField(
                controller: _nameController,
                label: "Full Name",
                hint: "Enter your full name",
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value!.isEmpty) return "Name cannot be empty";
                  if (value.length < 3) return "Name must be at least 3 characters";
                  return null;
                },
              ),

              // Email Field
              _buildInputField(
                controller: _emailController,
                label: "Email",
                hint: "Enter your email",
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return "Email cannot be empty";
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),

              // Password Field
              _buildInputField(
                controller: _passwordController,
                label: "Password",
                hint: "Enter your password",
                prefixIcon: Icons.lock,
                isPassword: true,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Password cannot be empty";
                  if (value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),

              // City Field
              _buildInputField(
                controller: _cityController,
                label: "City",
                hint: "Enter your city",
                prefixIcon: Icons.location_city,
                validator: (value) {
                  if (value!.isEmpty) return "City cannot be empty";
                  return null;
                },
              ),

              // WhatsApp Number Field
              _buildInputField(
                controller: _whatsappController,
                label: "Phone Number",
                hint: "Phone number",
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return "Phone number cannot be empty";
                  if (!RegExp(r'^\d{10,15}$').hasMatch(value)) return "Enter a valid phone number";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child:  Text(
                    "Register",
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Already have an account? Login
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login'); // Navigate to login screen
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: GoogleFonts.aBeeZee(
                      fontSize: 15,
                      color: Colors.blue.shade700,

                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Input Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,

        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600
          ),
          hintStyle: TextStyle(
              color: Colors.grey.shade600,
          ),
          hintText: hint,
          prefixIcon: Icon(prefixIcon, color: Colors.blue),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),

          // Border when active (focused)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2), // Change color here
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: validator,
      ),
    );
  }
}
