//friends page for the app, after someone clicks on the friends tab on bottom navigation bar

// import 'package:fitness/screens/friends.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/screens/login_screen.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:fitness/helpers/firebase_auth.dart';
import 'package:health/health.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
//icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/screens/friends.dart';
import 'package:fitness/screens/home.dart';

// import 'package:fitness/screens/profile.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  int selectedPage = 0;

_onTap() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => _pages[selectedPage])); // this has changed

  }
  final List<Widget> _pages = [
    HealthDataScreen(user: FirebaseAuth.instance.currentUser!),
    FriendsScreen(),
    // SettingsScreen(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Friends'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Friends'),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage,
        items: const [
          //home page, friends page, settings page, competing page
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Friends",
            backgroundColor: Colors.amber,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.run_circle_outlined),
            label: "Competing",
            backgroundColor: Colors.redAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
            backgroundColor: Colors.black,
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
            _onTap();
        },
      ),


    );
  }
}