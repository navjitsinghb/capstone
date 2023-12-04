//friends page for the app, after someone clicks on the friends tab on bottom navigation bar

// import 'package:fitness/screens/friends.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:health/health.dart';
// ignore: unused_import
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/screens/home.dart';
import 'package:fitness/screens/settings.dart';
import 'package:fitness/screens/competing.dart';

// import 'package:fitness/screens/profile.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  int selectedPage = 0;
  String user = FirebaseAuth.instance.currentUser!.displayName.toString();
_onTap() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => _pages[selectedPage])); // this has changed

  }
  final List<Widget> _pages = [
    FriendsScreen(),
    HealthDataScreen(user: FirebaseAuth.instance.currentUser!),
    CompetingScreen(),
    SettingsScreen(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('${user} Friends'),
        automaticallyImplyLeading: false, // Disable automatic back arrow

        centerTitle: true,
      ),
      body: 
      SingleChildScrollView(
        child: Column(
          children: [
            //first look into friends list then find the uid of the friend
            //then look into the users collection and find the user with the uid
            //then get the uid of the friend and display the uid of the friend
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('friends').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              return Column(
                //return fetched data function
                children: snapshot.data!.docs.map((document) {
                  return Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            fetchFriendsData();
                          },
                          child: Text(document['uid']),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
              );
              },
            ),
          ],
        ),
      ),




        bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage,
        items: const [
          //home page, friends page, settings page, competing page
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Friends",
            backgroundColor: Colors.amber,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Colors.black,
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
//display friends subcollection of the user data
  Future<void> fetchFriendsData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Call the user's CollectionReference to add a new user
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('friends')
        .get();
    //display friends subcollection data
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Friends'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(doc.toString()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }





}