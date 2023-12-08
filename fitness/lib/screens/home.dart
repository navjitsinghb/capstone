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
import 'package:fitness/screens/competing.dart';
import 'package:fitness/screens/settings.dart';
import 'package:fitness/helpers/goalCard.dart';
//import footstep icon
import 'package:flutter/widgets.dart';

Image kcalImage = Image.asset('assets/images/kcal.png');
Image footstepsImage = Image.asset('assets/images/footsteps.png');
Image distanceImage = Image.asset('assets/images/running.png');


class HealthDataScreen extends StatefulWidget {
  final User user;

  HealthDataScreen({required this.user});
  @override
  _HealthDataScreenState createState() => _HealthDataScreenState(user.uid);
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? heartRate;
  String? bp;
  String? steppage; //for homecard
  double? steps = 52; 
  double? activeEnergy = 10;
  double? running = 20;
  String? calories;

  String? formSteps;
  String? formCalories;
  String? formDistance;

  String? bloodPreSys;
  String? moveMins;
  String? bloodPreDia;
  String? workout;
  String? distance;
  bool isRefreshing = false;
  final uid = FirebaseAuth.instance.currentUser!.uid;


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
    CompetingScreen(),
    SettingsScreen(),
  ];



  List<HealthDataPoint> healthData = [];

  HealthFactory health = HealthFactory();

  @override
  void initState() { 
    super.initState();
    fetchData();
  } //this void function is called when the app is opened and it fetches the data from the health plugin and shows it in the app

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    // define the types to get
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.EXERCISE_TIME,
      HealthDataType.WORKOUT,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    ];

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 2)); //within the past week

    // requesting access to the data types before reading them
    bool requested = await health.requestAuthorization(types);
    if (requested) {
      try {
        // fetch health data
        healthData = await health.getHealthDataFromTypes(yesterday, now, types);//get health data from yesterday to now
        //fetch data and store in firebase firestore


        if (healthData.isNotEmpty) {
          for (HealthDataPoint h in healthData) {
            if (h.type == HealthDataType.HEART_RATE) {
              heartRate = "${h.value}";
              bloodPreSys = "${h.value}";
            } else if (h.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
              bloodPreDia = "${h.value}";
            } else if (h.type == HealthDataType.STEPS) {
              steps = "${h.value}" as double?;
              steppage = "${h.value}";
            } else if (h.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              calories = "${h.value}";
            }
            //workout 
            else if (h.type == HealthDataType.WORKOUT) {
              workout = "${h.value}";
            }
            else if (h.type == HealthDataType.EXERCISE_TIME) {
              moveMins = "${h.value}";
            }
            else if (h.type == HealthDataType.DISTANCE_WALKING_RUNNING) {
              distance = "${h.value}";
              running = "${h.value}" as double?;
            }


          if (bloodPreSys != "null" && bloodPreDia != "null") {
            bp = "$bloodPreSys / $bloodPreDia mmHg";
          }
          final uid = FirebaseAuth.instance.currentUser!.uid;
          _firestore.collection('users').doc(uid).update({
            'heart rate': heartRate,
            'blood pressure': bp,
            'steps': steps,
            'calories': activeEnergy,
            'workout': workout,
            'move minutes': moveMins,
            'distance': distance,
                });
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
  Future<void> _refreshData () async {
    setState(() {
      isRefreshing = true;
    });
    setState(() {
      fetchData();
      isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: display username of user and healthdata
        title: Text("Welcome ${widget.user.displayName}"), //${widget.user.displayName}
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
      //refresh indicator
      RefreshIndicator(
        onRefresh: () async {
          await _refreshData();
          // 2 second delay
          await Future.delayed(const Duration(seconds: 2));
        },
        child:
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        //health data cards
        child: 
        Column(
          children: [
            //press a button to fill out a form to add goals
            GestureDetector(
              onTap: () async {
                final uid = FirebaseAuth.instance.currentUser!.uid;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Add Goals'),
                      content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //steps per day
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Steps per day'),
                              keyboardType: TextInputType.number,
                              validator: (formSteps) {
                                if (formSteps == null || formSteps.isEmpty) {
                                  return 'Please enter steps per day';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formSteps = value;
                              },
                            ),
                            //calories per day
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Calories per day'),
                              keyboardType: TextInputType.number,
                              validator: (formCalories) {
                                if (formCalories == null || formCalories.isEmpty) {
                                  return 'Please enter calories per day';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formCalories = value;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Distance in miles'),
                              keyboardType: TextInputType.number,
                              validator: (formDistance) {
                                if (formDistance == null || formDistance.isEmpty) {
                                  return 'Please enter distance you want to walk/run';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formDistance = value;
                              },
                            )
                          ],
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              //save data from form state
                              _formKey.currentState!.save();
                              print(formSteps);
                              print(formCalories);
                              print(formDistance);
                              _firestore.collection('users').doc(uid).update({
                                'step goals': formSteps,
                                'calorie goals': formCalories,
                                'distance goals': formDistance,
                                'heart rate': heartRate,
                                'blood pressure': bp,
                                'steps': steps,
                                'calories': activeEnergy,
                                'workout': workout,
                                'move minutes': moveMins,
                                'distance': distance,
                              });
                              Navigator.pop(context);
                              //refresh home page
                              setState(() {
                                
                              });
                            }
                          },
                          child: const Text('Submit'),
                    ),
                  ],
                );
              },
            );
          },
            // child: 
            // const Text('Add Goals'),
          // ),

          //display home card data with steps and calories
child: Column(
  children: [
    // Call firestore data
    StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Loading...");
        }
        var userDocument = (snapshot.data! as DocumentSnapshot).data() as Map<String, dynamic>;
        // Calories and steps
        return Column(
          children: [
            HomeCard(
              title: "Steps",
            goal: userDocument['step goals'] ?? "0.0",
              iconPath: "assets/images/footsteps.png",
              heading: "Steps",
              value: steps ?? 0,
            ),
            const SizedBox(height: 10),
            HomeCard(
              title: "Calories",
              goal: userDocument['calorie goals'] ?? "0.0",
              iconPath: "assets/images/kcal.png",
              heading: "Calories",
              value: activeEnergy ?? 0,
            ),
            HomeCard(
              title: "Distance",
              goal: userDocument['distance goals'] ?? "0",
              iconPath: "assets/images/running.jpeg",
              heading: "Distance",
              value: running ?? 0,
            ),
          ],
        );
      },
    ),
    const SizedBox(height: 10),
  ],
),
        ),

            //health data cards
            Row(
              children: [
                Expanded(
                    child: healthCard(
                        title: "Heart rate",
                        image: "assets/images/health.jpeg",
                        data: heartRate ?? "72 bpm",
                        color: const Color(0xFFffffff))), //white color code: 0xFFffffff
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Blood pressure",
                        data: bp ?? "119/70 mm Hg", //what does line do?
                        image: "assets/images/blood-pressure.jpeg",
                        color: const Color(0xFFffffff))),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: healthCard(
                        title: "Step count",
                        image: "assets/images/step.jpeg",
                        data: "$steps Steps", //data of steps that user has taken and ?? means if null then show null
                        color: const Color(0xFFffffff))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Calories burned",
                        image: "assets/images/kcal.jpeg",
                        data: "$activeEnergy kcal",
                        color: const Color(0xFFffffff))
                        ),
              ],
            )
          ],
        ),
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
//form to fill out to find out how many steps and calories the user wants to burn per day
  Future<Form> _buildForm() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          //steps per day
          TextFormField(
            decoration: const InputDecoration(labelText: 'Steps per day'),
            keyboardType: TextInputType.number,
            validator: (formSteps) {
              if (formSteps == null || formSteps.isEmpty) {
                return 'Please enter steps per day';
              }
              return null;
            },
          ),
          //calories per day
          TextFormField(
            decoration: const InputDecoration(labelText: 'Calories per day'),
            keyboardType: TextInputType.number,
            validator: (formCalories) {//validator to make sure form is not empty
              if (formCalories == null || formCalories.isEmpty) {
                return 'Please enter calories per day';
              }
              return null;
            },
          ),
          //submit button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {//if form is not empty
                //add data to firestore
                _firestore.collection('users').doc(uid).update({
                    'step goals': formSteps,
                    'calorie goals': formCalories,
                  });
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
 //remove from friends list
  Future<void> _removeFriend(String friendId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'friends': FieldValue.arrayRemove([friendId]),
    });
  }
//remove from competing list
  Future<void> _removeFriend1(String friendId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'competing': FieldValue.arrayRemove([friendId]),
    });
  }

  //add goals to firestore
  Future<void> _addGoals(num steps, num calories) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'step goals': steps,
      'calorie goals': calories,
    });
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
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .get();
    //print out friends userID

      //check if name in textbox is in database
    if (querySnapshot.docs.isNotEmpty) {
      String friendUserId = querySnapshot.docs.first.id;
      // print(userId);
      //if current signed in user tries to add themselves, show user not found dialog
      if (name == FirebaseAuth.instance.currentUser!.displayName) {
        _showUserNotFoundDialog(context);
        return;
      }
      //if name is in database, show dialog
      _showUserFoundDialog(context, name);
      //add data to friends list
      Future<void> users1 = FirebaseFirestore.instance.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendUserId]),
      });
      //shows all uid in firestore
      //get data and seperate each field by comma
      final allData = querySnapshot.docs.map((doc) => doc.data()).toList(); // Get all data
      // Future<void> users = FirebaseFirestore.instance.collection('users').doc(userId).collection('friends').add({
      //   'friends': allData,
      // });
    } else {
      //if name is not in database, show dialog
      _showUserNotFoundDialog(context);
    }
  }
  Future<void> fetchAllUserData() async {
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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
  //get all friendsIds in the friends list in firestore
  List<String> friendsList = [];
  List<String> friendsNames = [];
  List<String> friendsIds = [];
  //get all friendsIds in the friends list in firestore
  //for each doc that is equal to the friends list id, add to friends list
  querySnapshot.docs.forEach((doc) {
    if (doc.id == uid ) {// if doc id is not equal to current user id and friends list contains current user id
      friendsList = List.from(doc['friends']);
    }

  });
querySnapshot.docs.forEach((doc) {
  if (friendsList.contains(doc.id)) {
    var names = doc['name'] as String;
    friendsNames.add(names);
    var ids = doc.id as String;
    friendsIds.add(ids);

  }
});
  print(friendsNames);

  //print each of the friends names in their own line and put the 3 dot overflow menu on the right side of each name that the person can click on to see whther they want to compete with that person or not, or remove them from their friends list, or going back to the friends list
  // ignore: use_build_context_synchronously
  showDialog(context: context, 
  builder: (BuildContext context) {
  return Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: Icon(Icons.close),
      onPressed: () {
        // Handle the "X" button press to go back to the home screen
        Navigator.pop(context);
      },
    ),
    title: Text('Friends List'),
  ),
        body: Container(
          height: 200,
          child:
        Card(
        child:
        ListView.builder(
          itemCount: friendsNames.length,
          itemBuilder: (context, index) {
            String friendName = friendsNames[index];
            String friendId = friendsIds[index];
            return ListTile(
              title: Text(friendName),
              trailing: PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'compete',
                    child: Text('Compete with $friendName'),
                  ),
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Text('Remove $friendName from friends list'),
                  ),
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Text('Remove $friendName from competing'),
                  )
                ],
                onSelected: (String value) {
                  if (value == 'compete') {
                    // Handle the "Compete" action
                    //add id of friend to competing array in firestone in current user and go to competing page
                    _firestore.collection('users').doc(uid).update({
                      'competing': FieldValue.arrayUnion([friendId]),
                    });
                  } else if (value == 'remove') {
                    // Handle the "Remove" action
                    //remove friends from friends list
                    _removeFriend(friendName);
                  } else if (value == 'remove') {
                    // Handle the "Remove" action
                    //remove friends from friends list
                    _removeFriend1(friendName);
                  }
                },
              ),
            );
          },
        ),
        ),
        ),
    );
},
);
}



Widget healthCard(
    {String title = "",
    String data = "",
    Color color = Colors.black,
    required String image}) {
  return Container(
    height: 180,
    margin: const EdgeInsets.symmetric(vertical: 5),
    padding: const EdgeInsets.symmetric(vertical: 5),
    //border color
    decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
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
