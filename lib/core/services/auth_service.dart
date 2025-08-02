import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'

class AuthenticationService
{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  //Signup with email & password
  Future<User?> signUpWithEmail(String email,String password,String name,String city,String dob,String phoneNo,userType) async
  {
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if(user!=null)
      {
        print("User created");
        // store data in fire store

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'city': city,
          'dob': dob,
          'phoneNo' : phoneNo,
          'userType':userType
        });


      }
      else print("not created");
      return user;
    } catch(e){
      print("Error during sign up : $e");
      return null;
    }
  }
  Future<User?> signInWithEmail(String email,String password) async
  {
    try
    {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    }catch (e)
    {
      print("Exception :  $e");
      return null;
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
