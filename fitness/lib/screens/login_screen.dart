// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fitness/screens/name.dart';
import 'package:fitness/screens/signup_screen.dart';
import 'package:fitness/screens/home.dart';

import '../helpers/firebase_auth.dart';
import '../helpers/validator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  // final _phoneTextController = TextEditingController();
  // final _nameTextController = TextEditingController();
  // final _phoneCodeSent = TextEditingController();
  // final _verificationCompleted = TextEditingController();
  // final _verificationFailed = TextEditingController();
  // final _codeAutoRetrievalTimeout = TextEditingController();
  // final _phoneAuthCredentialSent = TextEditingController();


  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) { // if user is not null, then the user is already logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
          //  HealthApp(
            // user: user,
          HealthDataScreen(
            user: user,
          ),
        ),
      );
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: Text('Fitness App'),
          automaticallyImplyLeading: false, // Disable automatic back arrow
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0,top: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.asset("assets/images/bolt.png", fit: BoxFit.contain),
                      //background color: Colors.lightBlueAccent,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30.0,top: 12),
                      child: Text(
                        'Welcome People',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40
                        )
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
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
                          SizedBox(height: 8.0),
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
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.0),
                          _isProcessing
                          ? CircularProgressIndicator()
                          : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _focusEmail.unfocus();
                                    _focusPassword.unfocus();

                                    if (_formKey.currentState!
                                        .validate()) {
                                      setState(() {
                                        _isProcessing = true;
                                      });

                                      User? user = await FirebaseAuthHelper
                                          // .signInUsingPhoneNumber(phoneNumber: _phoneTextController.text, 
                                          // phoneAuthCredentialSent: (PhoneAuthCredential credential) {
                                          //   _phoneAuthCredentialSent.text = credential.toString();
                                          // }, 
                                          // phoneCodeSent: (String verificationId, int? resendToken) {
                                          //   _phoneCodeSent.text = verificationId;
                                          // }, 
                                          // verificationCompleted: (UserCredential userCredential) {
                                          //   _verificationCompleted.text = userCredential.user.toString();
                                          // }, 
                                          // verificationFailed: (FirebaseAuthException exception) {
                                          //   _verificationFailed.text = exception.toString();
                                          // }, 
                                          // codeAutoRetrievalTimeout: (String verificationId) {
                                          //   _codeAutoRetrievalTimeout.text = verificationId;
                                          // },
                                          .signInUsingEmailPassword(
                                        email: _emailTextController.text,
                                        password:
                                            _passwordTextController.text,
                                      );

                                      setState(() {
                                        _isProcessing = false;
                                      });

                                      if (user != null) { // if user is not null, then the user is already logged in
                                        Navigator.of(context)
                                            .pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HealthDataScreen(user: user,
                                                // HealthApp(
                                                //   user: user,
                                                ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent),
                                  ),
                                ),
                              ),
                              SizedBox(width: 24.0),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
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
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}