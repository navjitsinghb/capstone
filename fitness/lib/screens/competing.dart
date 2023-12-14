// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:fitness/screens/login_screen.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//icons
// ignore: unused_import
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
                        return collectionRef.doc(friendId).get();
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
                        CompetitorsCard win = CompetitorsCard(competitors: [], winner: '', competitorStats: {},);
                        final winner  = win._getWinner();
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
                              winner: winner ?? 'Null',
                              // winner: 'winner',
                            );
                          },
                        );
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
  late final String winner;
  //userId
  final String userId = FirebaseAuth.instance.currentUser!.uid.toString();
  //user
  final String user = FirebaseAuth.instance.currentUser!.displayName.toString();

  CompetitorsCard({
    required this.competitors,
    required this.competitorStats,
    required this.winner,
  });


  @override
  Widget build(BuildContext context) {
return Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),

  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      for (final competitor in competitors)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Competitor: $competitor',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      const Divider(
        color: Color.fromARGB(255, 0, 0, 0),
        thickness: 1,
      ),
      ListView.builder(
        shrinkWrap: true,
        itemCount: competitors.length,
        itemBuilder: (context, index) {
          winner ??= _getWinner();
          final competitor = competitors[index];
          final stats = competitorStats[competitor];
          final distance = stats?['distance'];
          final calories = stats?['calories'];
          final steps = stats?['steps'];
          return ListTile(
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Distance: $distance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: winner == competitor ? Colors.green : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Calories: $calories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: winner == competitor ? Colors.green : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Steps: $steps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: winner == competitor ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          // ignore: unnecessary_null_comparison, prefer_if_null_operators
          'Winner: ${winner != null ? winner : 'No winner'}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  ),
);
  }
//function to get commpetitor stats
  Map<String, Map<String, int>> _getCompetitorStats() {
    final competitorStats = <String, Map<String, int>>{};
    for (final competitor in competitors) {
      competitorStats[competitor] = {
        'distance': 0,
        'calories': 0,
        'steps': 0,
      };
    }
    return competitorStats;
  }
//function to get winner between current user and friend
  String _getWinnerBetween(String winner, String competitor) {
    final competitorStats = _getCompetitorStats();
    final currentDistance = competitorStats[user]?['distance'];
    final currentCalories = competitorStats[user]?['calories'];
    final currentSteps = competitorStats[user]?['steps'];
    final competitorDistance = competitorStats[competitor]?['distance'];
    final competitorCalories = competitorStats[competitor]?['calories'];
    final competitorSteps = competitorStats[competitor]?['steps'];
    int currentScore = 0;
    int competitorScore = 0;
    if (currentDistance! > competitorDistance!) {
      currentScore++;
    } else if (currentDistance < competitorDistance) {
      competitorScore++;
    }
    if (currentCalories! > competitorCalories!) {
      currentScore++;
    } else if (currentCalories < competitorCalories) {
      competitorScore++;
    }
    if (currentSteps! > competitorSteps!) {
      currentScore++;
    } else if (currentSteps < competitorSteps) {
      competitorScore++;
    }
    if (currentScore > competitorScore) {
      return user;
    } else if (currentScore < competitorScore) {
      return competitor;
    } else {
      return 'Tie';
    }
  }
//functions that will decide the winner, if competing friend has 2 out of 3 goals higher than current user then they win and winner is stored in firebase 
  String _getWinner() {
    final competitorStats = _getCompetitorStats();
    String winner = '';
    for (final competitor in competitors) {
      winner = _getWinnerBetween(winner, competitor);
    }
    if (winner != 'Tie') {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'winner': winner,
      });
    }
    return winner;
  }







}








