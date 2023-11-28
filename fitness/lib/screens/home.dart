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


class HealthDataScreen extends StatefulWidget {
  final User user;

  HealthDataScreen({required this.user});
  @override
  _HealthDataScreenState createState() => _HealthDataScreenState(user.uid);
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        automaticallyImplyLeading: false, // Disable automatic back arrow
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
              PopupMenuItem(
                child: TextButton(
                  onPressed: () async {
                    friendsList();
                  },
                  child: const Text("Friends List"),
                  ),
                )
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
                        data: heartRate ?? "72 bpm",
                        color: const Color(0xFF8d7ffa))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Blood pressure",
                        data: bp ?? "119/70 mm Hg", //what does line do?
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
                        data: steps ?? "900", //data of steps that user has taken and ?? means if null then show null
                        color: const Color(0xFF2086fd))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Calories burned",
                        image: "assets/images/kcal.jpeg",
                        data: activeEnergy ?? "1,200 kcal", 
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


void _searchForUser(BuildContext context, String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .get();
      if (name == name) {
        Future<void> users = FirebaseFirestore.instance.collection('users').doc(userId).update({
          'friends': FieldValue.arrayUnion([name])
        });
        _showUserFoundDialog(context, name);
      } else {
        _showUserNotFoundDialog(context);
      }
  }
  Future<void> fetchAllUserData() async {
  // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('users') //collection name
  //       .get(); // Get all documents
  //   final allData = querySnapshot.docs.map((doc) => doc.data()).toList(); // Get all data
  //   print(allData);
  FirebaseFirestore.instance.collection("users").get().then(
  (querySnapshot) {
    print("Successfully completed");
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList(); // Get all data
    print(allData);
  },
  onError: (e) => print("Error completing: $e"),);
}


  void _showUserFoundDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Found'),
          content: Text('Username: $name'),
          actions: [
            ElevatedButton(
              onPressed: () {
                content: Text('User $name was added to your friends list');
                Navigator.pop(context); // Close the dialog)
                //print that user was added to friends list 
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

//friends list for current user 
Future <void> friendsList() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  // show friends separated by commas
  final friends = doc['friends'].join(', ');
  // ignore: use_build_context_synchronously
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Friends List'),
        content: Text('Friends: $friends'),
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
        Column(
          children: [
            Image.asset(image, width: 70),
          ],
        ),
        Text(data),
      ],
    ),
  );
}

Textbutton({required Future Function() onPressed, required Text child}) {
}




}//end of class
