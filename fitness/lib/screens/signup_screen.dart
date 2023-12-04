// ignore: unused_import
// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, sort_child_properties_last

// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/screens/home.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fitness/screens/name.dart';
import 'package:fitness/helpers/firebase_auth.dart';
import 'package:fitness/helpers/validator.dart';
//firestone
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _phoneTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: Text('Create Account'),
          automaticallyImplyLeading: true, // Disable automatic back arrow
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left:24.0, right: 24.0, bottom: 425.0),

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nameTextController,
                        focusNode: _focusName,
                        validator: (value) => Validator.validateName(
                          name: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Name",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Email",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: true,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Password",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      _isProcessing
                      ? CircularProgressIndicator()
                      : Row(
                        //move button to bottom screen
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _isProcessing = true;
                                });

                                if (_registerFormKey.currentState!
                                    .validate()) {
                                  User? user = await FirebaseAuthHelper
                                        .registerUsingEmailPhonePassword(
                                          name: _nameTextController.text,
                                          email: _emailTextController.text,
                                          password: _passwordTextController.text,
                                        );
                                        //add user data to firestone
                                        _addUser(
                                          _nameTextController.text, 
                                        _emailTextController.text,  
                                        _passwordTextController.text);

                                  setState(() {
                                    _isProcessing = false;
                                  });

                                  if (user != null) {
                                    Navigator.of(context)
                                        .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            // HomeScreen(user: user),                                            
                                            HealthDataScreen(user: user ),
                                      ),
                                      ModalRoute.withName('/'),
                                    );
                                  }
                                }else{
                                  setState(() {
                                    _isProcessing = false;
                                  });
                                }
                              },
                              child: 
                              Text(
                                'Sign up',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //add user data to firestone with the userid being the unique identifier
  Future<void> _addUser(String name, String email, String password) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Call the user's CollectionReference to add a new user
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
          'name': name, // John Doe
          'email': email, // Stokes and Sons
          'password': password, // 42
          'uid': uid,
          //null
          'friends': [],
          'competing': [],
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

}