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
                    List<dynamic> compUserIds = (snapshot.data!.data() as Map<String, dynamic>)['competing'];
                    print(compUserIds);
                    CollectionReference<Map<String, dynamic>> collectionRef = FirebaseFirestore.instance.collection('users');
                    List<Future<DocumentSnapshot<Map<String, dynamic>>>> compFutures = compUserIds.map((friendId) {
                        return collectionRef.doc(friendId).get() as Future<DocumentSnapshot<Map<String, dynamic>>>;
                    }).toList();

                    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                      future: Future.wait(compFutures),
                      builder: (context, AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>> snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Loading...");
                        }
                        List<DocumentSnapshot<Map<String, dynamic>>> compsData = snapshot.data!;
                        // for (int index = 0; index < compsData.length; index++) {
                        //     DocumentSnapshot<Map<String, dynamic>> friendDocument = compsData[index];
                        //     String friendsList = friendDocument['name'];
                        //     print(friendsList);

                        // }
                        // list view
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: compsData.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot<Map<String, dynamic>> friendDocument = compsData[index];
                            String friendsList = friendDocument['name'];
                            return CompetitorsCard(
                              competitors: [friendsList],
                              competitorStats: {
                                friendsList: {
                                  'distance': (friendDocument['distance'] ?? 0).toInt(),
                                  'calories': (friendDocument['calories'] ?? 0).toInt(),
                                  'steps': (friendDocument['steps'] ?? 0).toInt(),
                                },
                              },
                              winner: "",
                            );
                            

                            // return ListTile(
                            //   title: Text(friendsList),
                            //   trailing: Icon(Icons.emoji_events),
                            //   onTap: () {
                            //     // Navigator.push(
                            //     //   context,
                            //     //   MaterialPageRoute(builder: (context) => CompetingScreen()),
                            //     // );
                            //   },
                            // );
                          },
                        );





                    // Stream<QuerySnapshot<Map<String, dynamic>>> collectionRef2 = FirebaseFirestore.instance.collection('users').where('users', whereIn: compUserIds).snapshots();

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
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
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
  List<DocumentSnapshot<Map<String, dynamic>>> compsData = friendsList.map((friendId) => collectionRef.doc(friendId).get()).cast<DocumentSnapshot<Map<String, dynamic>>>().toList();
  return compsData;
}




}//end of competing screen stateful widget



//goal card2 function to show progress of competitors and who is winning along with their stats like distance, cals, and steps so far and the winner at the end of the day gets a notification that says they won
class CompetitorsCard extends StatelessWidget {
  final List<String> competitors;
  final Map<String, Map<String, int>> competitorStats;
  final String winner;

  CompetitorsCard({
    required this.competitors,
    required this.competitorStats,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const Text(
            'Competitors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemCount: competitors.length,
            itemBuilder: (context, index) {
              final competitor = competitors[index];
              final stats = competitorStats[competitor];
              final distance = stats?['distance'];
              final calories = stats?['calories'];
              final steps = stats?['steps'];
              return ListTile(
                title: Text(competitor),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance: $distance'),
                    Text('Calories: $calories'),
                    Text('Steps: $steps'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Winner: $winner',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}








