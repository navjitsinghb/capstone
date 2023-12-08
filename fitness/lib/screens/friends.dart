//friends page for the app, after someone clicks on the friends tab on bottom navigation bar
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
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
import 'package:fitness/helpers/goalCard.dart';
Image kcalImage = Image.asset('assets/images/kcal.png');
Image footstepsImage = Image.asset('assets/images/footsteps.png');

// import 'package:fitness/screens/profile.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String? userId;
  late final String heading;
  late final double value;
  late final double goal;
  late final String iconPath;
  final TextStyle _titleStyle = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: AppFont.nunito,
  );
  // _FriendsScreenState({this.userId});
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

  final String userID = FirebaseAuth.instance.currentUser!.uid;//current user id
  final String collectionName = 'users';

  Stream<dynamic> findFriends() async* {
    try {
      // Get a reference to the Firestore collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection(collectionName);

      // Get the user's document by userId
      DocumentSnapshot userDocument = await usersCollection.doc(userID).get();

      if (userDocument.exists) {
        // Retrieve the friends' userIds from the user's document
        List<dynamic> friendUserIds = userDocument['friends'];

        // Get the friends' documents based on their userIds
        List<DocumentSnapshot> friendDocuments = await Future.wait(
          friendUserIds.map((friendId) {
            return usersCollection.doc(friendId).get();
          }),
        );

        // Log or process the friends' data
        friendDocuments.forEach((friendDocument) {
          print('Friend data: ${friendDocument.data()}');
        });
      } else {
        print('User not found.');
      }
    } catch (e) {
      print('Error getting friends data: $e');
    }
  }
  //goalcard2 widtget: display all goals on card like previous goalcard
Widget goalCard2(String goal, String iconPath, String heading, double value) {
  return Container(
    height: 85,
    width: MediaQuery.of(context).size.width,
    // decoration: BoxDecoration(
      // border: Border.all(color: Colors.black),
      // borderRadius: BorderRadius.circular(1),
    // ),
    //add padding 

    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 25,0),//padding for the card
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Text.rich(
              //   TextSpan(
              //     children: [
              //       TextSpan(
              //         text: '$name',
              //         style: const TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w400,
              //           fontFamily: AppFont.montserrat,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$heading: ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppFont.montserrat,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: value / 100,
                    valueColor: AlwaysStoppedAnimation(
                      context.themeValue(light: const Color.fromARGB(255, 0, 0, 0), dark: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    backgroundColor: const Color.fromARGB(255, 122, 118, 118),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${AppText.steps}: $value',
                    style: _titleStyle,
                  ),
                  Text(
                    '${AppText.goal}: $goal',
                    style: _titleStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 25,
          width: 25,
          child: Image.asset(iconPath),
        )
      ],
    ),
    ),
  );
}
Widget goalCard3(String name, String goal, String iconPath, String heading, double value) {
  return Container(
    height: 85,
    width: MediaQuery.of(context).size.width,
    // decoration: BoxDecoration(
      // border: Border.all(color: Colors.black),
      // borderRadius: BorderRadius.circular(1),
    // ),
    //add padding 

    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 25,0),//padding for the card
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFont.montserrat,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$heading: ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppFont.montserrat,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: value / 100,
                    valueColor: AlwaysStoppedAnimation(
                      context.themeValue(light: const Color.fromARGB(255, 0, 0, 0), dark: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    backgroundColor: const Color.fromARGB(255, 122, 118, 118),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${AppText.steps}: $value',
                    style: _titleStyle,
                  ),
                  Text(
                    '${AppText.goal}: $goal',
                    style: _titleStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 25,
          width: 25,
          child: Image.asset(iconPath),
        )
      ],
    ),
    ),
  );
}
  
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
            //goalcard
          Container(
            child: Column(
              children: [
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get() as Future<DocumentSnapshot<Map<String, dynamic>>>,
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }
                  CollectionReference usersCollection = FirebaseFirestore.instance.collection(collectionName);
                  Future<DocumentSnapshot<Map<String, dynamic>>>? userDocument = usersCollection.doc(userID).get() as Future<DocumentSnapshot<Map<String, dynamic>>>?;
                  if (snapshot.hasData) {
                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: userDocument,
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Loading user data");
                        }

                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          List<dynamic> friendUserIds = (userSnapshot.data!.data() as Map<String, dynamic>)['friends'];
                          List<Future<DocumentSnapshot<Map<String, dynamic>>>> friendFutures = friendUserIds.map((friendId) {
                            return usersCollection.doc(friendId).get() as Future<DocumentSnapshot<Map<String, dynamic>>>;
                          }).toList();

                          return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                            future: Future.wait(friendFutures),
                            builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>> friendSnapshot) {
                              if (friendSnapshot.connectionState == ConnectionState.waiting) {
                                return const Text("Loading friend data");
                              }
                              for (var friend in friendSnapshot.data!) {
                                print(friend.data());
                              }

                              if (friendSnapshot.hasData) {
                                List<DocumentSnapshot<Map<String, dynamic>>> friendDocuments = friendSnapshot.data!;
                                List<Widget> goalscards = friendDocuments.map((friendDocument) {
                                  return Column(
                                    children: 
                                    [
                                      //goalcard2
                                      goalCard3(
                                        friendDocument['name'],
                                        friendDocument['step goals'], 
                                        'assets/images/footsteps.png', 
                                        'Steps', 
                                        friendDocument['steps']),
                                      goalCard2(
                                        friendDocument['calorie goals'], 
                                        'assets/images/kcal.png', 
                                        'Calories', 
                                        friendDocument['calories']),
                                    ],
                                  );
                                }).toList();
                                //goalcard2 for future widget
                                List<Widget> friendWidget = goalscards.map((goalcard) {
                                  return SizedBox(
                                    height: 200, //MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    child: 
                                        Card(
                                          margin: const EdgeInsets.all(8),
                                          shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                            //border color black
                                          side: const BorderSide(color: AppColor.black),
                                        ),
                                        child:
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Flexible(child: goalcard),
                                                  ],
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList();
                                return Column(
                                  children: 
                                  //wrap goalscards in a widget that keeps each friend seperate
                                  friendWidget,

                                );
                              }

                              return const Text('No friend data available');
                            },
                          );
                        }

                        return const Text('User data not found');
                      },
                    );
                  }

                  return const Text('No data available');
                },
              ),
              ],
            ),
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
            backgroundColor: Color.fromARGB(255, 161, 146, 72),
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



  //first look into friends list then use that uid and retrieve the user data
  Future<void> fetchFriendsData2() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Call the user's CollectionReference to add a new user
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    //display friends subcollection data
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Friends'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(doc.toString()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
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
//friends page for the app, after someone clicks on the friends tab on bottom navigation bar