import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/screens/login_screen.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:flutter/material.dart';
//icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//firestone
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/screens/friends.dart';
import 'package:fitness/screens/home.dart';
import 'package:fitness/screens/settings.dart';


class CompetingScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CompetingScreenState createState() => _CompetingScreenState();
}

class _CompetingScreenState extends State<CompetingScreen> {
  int selectedPage = 0;
  String user = FirebaseAuth.instance.currentUser!.displayName.toString();
  String userId = FirebaseAuth.instance.currentUser!.uid.toString();
  
  _onTap() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => _pages[selectedPage])); // this has changed

  }
  final List<Widget> _pages = [
    //competing page, home page, friends page, settings page
    CompetingScreen(),
    HealthDataScreen(user: FirebaseAuth.instance.currentUser!),
    FriendsScreen(),
    SettingsScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('${user} Competing'),
        automaticallyImplyLeading: false, // Disable automatic back arrow
        centerTitle: true,
      ),
      //shows friend's name and if both current user and friend are in each other friends array then compete with them to see who has more steps
      body: 
        SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text('Competing'),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("Loading...");
                    }
                    DocumentSnapshot<Map<String, dynamic>> userDocument = snapshot.data!;
                    // Put all friends list into a list
                    List<dynamic> friendUserIds = (snapshot.data!.data() as Map<String, dynamic>)['friends'];
                    print(friendUserIds);
                    CollectionReference<Map<String, dynamic>> collectionRef = FirebaseFirestore.instance.collection('users');
                    List<Future<DocumentSnapshot<Map<String, dynamic>>>> friendFutures = friendUserIds.map((friendId) {
                        return collectionRef.doc(friendId).get() as Future<DocumentSnapshot<Map<String, dynamic>>>;
                    }).toList();

                    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                      future: Future.wait(friendFutures),
                      builder: (context, AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>> snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Loading...");
                        }
                        List<DocumentSnapshot<Map<String, dynamic>>> friendsData = snapshot.data!;
                        // for (int index = 0; index < friendsData.length; index++) {
                        //     DocumentSnapshot<Map<String, dynamic>> friendDocument = friendsData[index];
                        //     String friendsList = friendDocument['name'];
                        //     print(friendsList);

                        // }
                        // list view
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: friendsData.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot<Map<String, dynamic>> friendDocument = friendsData[index];
                            String friendsList = friendDocument['name'];
                            print(friendsList);
                            return ListTile(
                              title: Text(friendsList),
                              trailing: Icon(Icons.emoji_events),
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => CompetingScreen()),
                                // );
                              },
                            );
                          },
                        );





                    // Stream<QuerySnapshot<Map<String, dynamic>>> collectionRef2 = FirebaseFirestore.instance.collection('users').where('users', whereIn: friendUserIds).snapshots();

                    return Container(); // Placeholder return statement
                  },
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
            icon: Icon(Icons.emoji_events),
            label: 'Competing',
            backgroundColor: Colors.lightBlueAccent,
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
            icon: Icon(Icons.settings),
            label: 'Settings',
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



fetchFriendData (String friendId) async {
  CollectionReference<Map<String, dynamic>> collectionRef = FirebaseFirestore.instance.collection('users');
  DocumentSnapshot<Map<String, dynamic>> friendDocument = await collectionRef.doc(friendId).get();
  List<dynamic> friendsList = friendDocument['friends'];
  List<DocumentSnapshot<Map<String, dynamic>>> friendsData = friendsList.map((friendId) => collectionRef.doc(friendId).get()).cast<DocumentSnapshot<Map<String, dynamic>>>().toList();
  return friendsData;
}

}//end of competing screen stateful widget

