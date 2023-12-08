import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/screens/login_screen.dart';
// ignore: unused_import
import 'package:fitness/helpers/firebase_auth.dart';
import 'package:health/health.dart';
import 'package:flutter/material.dart';
//icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//firestone
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/screens/friends.dart';
import 'package:fitness/screens/home.dart';
import 'package:fitness/screens/competing.dart';
// import 'package:fitness/screens/settings.dart';


class SettingsScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int selectedPage = 0;
  String user = FirebaseAuth.instance.currentUser!.displayName.toString();
  
  _onTap() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => _pages[selectedPage])); // this has changed

  }
  final List<Widget> _pages = [
    //competing page, home page, friends page, settings page
    SettingsScreen(),
    HealthDataScreen(user: FirebaseAuth.instance.currentUser!),
    FriendsScreen(),
    CompetingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('${user} Settings'),
        automaticallyImplyLeading: false, // Disable automatic back arrow
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings'),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage,
        items: const [
          //home page, friends page, settings page, competing page
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.lightBlueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
            backgroundColor: Colors.lightBlueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Competing',
            backgroundColor: Colors.lightBlueAccent,
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




}//end of competing screen stateful widget

