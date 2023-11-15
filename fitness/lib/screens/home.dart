//from login page to this page 

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
//firestone
import 'package:cloud_firestore/cloud_firestore.dart';
//friends page
import 'package:fitness/screens/friends.dart';


// class HealthApp extends StatelessWidget {
//   const HealthApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "My Health Data",
//       home: HealthDataScreen(user: FirebaseAuth.instance.currentUser!),
//       themeMode: ThemeMode.dark,
//       darkTheme: ThemeData(
//           brightness: Brightness.dark,
//           scaffoldBackgroundColor: const Color(0xFF101820),
//           appBarTheme: const AppBarTheme(color: Color(0xFF101820))),
//     );
//   }
// }

class HealthDataScreen extends StatefulWidget {
  final User user;

  HealthDataScreen({required this.user});
  @override
  _HealthDataScreenState createState() => _HealthDataScreenState(user.uid);
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  String? heartRate;
  String? bp;
  String? steps;
  String? activeEnergy;

  String? bloodPreSys;
  String? bloodPreDia;

  final String? userId;
  
  _HealthDataScreenState(this.userId);
  final TextEditingController _searchController = TextEditingController();

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



  List<HealthDataPoint> healthData = [];

  HealthFactory health = HealthFactory();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    // define the types to get
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 2));

    // requesting access to the data types before reading them
    bool requested = await health.requestAuthorization(types);

    if (requested) {
      try {
        // fetch health data
        healthData = await health.getHealthDataFromTypes(yesterday, now, types);

        if (healthData.isNotEmpty) {
          for (HealthDataPoint h in healthData) {
            if (h.type == HealthDataType.HEART_RATE) {
              heartRate = "${h.value}";
            } else if (h.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
              bloodPreSys = "${h.value}";
            } else if (h.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
              bloodPreDia = "${h.value}";
            } else if (h.type == HealthDataType.STEPS) {
              steps = "${h.value}";
            } else if (h.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              activeEnergy = "${h.value}";
            }
          }
          if (bloodPreSys != "null" && bloodPreDia != "null") {
            bp = "$bloodPreSys / $bloodPreDia mmHg";
          }

          setState(() {});
        }
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      healthData = HealthFactory.removeDuplicates(healthData);
    } else {
      print("Authorization not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: display username of user and healthdata
        title: Text("Welcome ${widget.user.displayName}"),
        actions: [
          //three dot overflow menu
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: TextButton(
                  onPressed: () async {
                    _logoutButton();
                    // await FirebaseAuth.instance.signOut();
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: const Text("Logout"),
                ),
                //add friend button
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () async { //search for username with a form
                    _showAddFriendForm(context);


                  },
                  child: const Text("Add Friend"),
                ),
              ),
              //notification button
              PopupMenuItem(
                child: TextButton(
                  onPressed: () async {

                  },
                  child: const Text("Notifications"),
                ),
              ),
            ],
          ),

        ],
      ),
      body:
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: 
        Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: healthCard(
                        title: "Heart rate",
                        image: "assets/images/health.jpeg",
                        data: heartRate != "null" ? "$heartRate bpm" : "heart rate",
                        color: const Color(0xFF8d7ffa))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Blood pressure",
                        data: bp ?? "Beats per minute", //what does line do?
                        image: "assets/images/blood-pressure.jpeg",
                        color: const Color(0xFF4fd164))),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: healthCard(
                        title: "Step count",
                        image: "assets/images/step.jpeg",
                        data: steps ?? "null",
                        color: const Color(0xFF2086fd))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Calories burned",
                        image: "assets/images/kcal.jpeg",
                        data: activeEnergy != "null" ? "$activeEnergy cal" : "",
                        color: const Color(0xFFf77e7e))
                        ),
              ],

            )
          ],
        ),
      ),
      //bottom navigation bar
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
  Future<void> _logoutButton() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    void _showAddFriendForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search for Friends'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(labelText: 'Enter username'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _searchForUser(context, _searchController.text);
                },
                child: const Text('Search'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchForUser(BuildContext context, String username) {
    // Perform a Firestore query to search for the user
    FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // User found, you can add friend logic here
        Navigator.pop(context); // Close the search form
        _showUserFoundDialog(context, querySnapshot.docs.first);
      } else {
        // User not found
        _showUserNotFoundDialog(context);
      }
    });
  }

  void _showUserFoundDialog(BuildContext context, DocumentSnapshot userSnapshot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Found'),
          content: Text('Username: ${userSnapshot['username']}'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Add friend logic here
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Add Friend'),
            ),
          ],
        );
      },
    );
  }

  void _showUserNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Not Found'),
          content: const Text('Sorry, the user was not found.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

//adding friends with firestone 
//how to add friends with firestone: 


Widget healthCard(
    {String title = "",
    String data = "",
    Color color = Colors.blue,
    required String image}) {
  return Container(
    height: 240,
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(20))),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Image.asset(image, width: 70),
        Text(data),
      ],
    ),
  );
}

Textbutton({required Future Function() onPressed, required Text child}) {
}

//adding friends with firestone
//add user data from firebase auth to firestone
void addDataToFirestone(String userId, String username){
  FirebaseFirestore.instance.collection('users').doc(userId).set({
    'username': username,
    'friends': [], // Initialize an empty array for friends
    'friendRequests': [], // Initialize an empty array for friend requests
  });
}

//read data from firestone
void readDataFromFirestone(){
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  users.get().then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      print(doc["name"]);
      print(doc["email"]);
    });
  });
}
//send friends request using firestone
void sendFriendRequest(String senderId, String receiverId) {
  FirebaseFirestore.instance.collection('users').doc(receiverId).update({
    'friendRequests': FieldValue.arrayUnion([senderId]),
  });
}//what does this function do exactly? 
//accept friend request using firestone
void acceptFriendRequest(String senderId, String receiverId) {
  FirebaseFirestore.instance.collection('users').doc(receiverId).update({
    'friendRequests': FieldValue.arrayRemove([senderId]),
    'friends': FieldValue.arrayUnion([senderId]),
  });
  FirebaseFirestore.instance.collection('users').doc(senderId).update({
    'friends': FieldValue.arrayUnion([receiverId]),
  });
}




}//end of class
