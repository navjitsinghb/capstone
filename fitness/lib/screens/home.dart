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
  _HealthDataScreenState createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  String? heartRate;
  String? bp;
  String? steps;
  String? activeEnergy;

  String? bloodPreSys;
  String? bloodPreDia;

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
    final yesterday = now.subtract(const Duration(days: 1));

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
        title: const Text("My Health Data"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: healthCard(
                        title: "Heart rate",
                        image: "assets/images/health.jpeg",
                        data: heartRate != "null" ? "$heartRate bpm" : "",
                        color: const Color(0xFF8d7ffa))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Blood pressure",
                        data: bp ?? "",
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
                        data: steps ?? "",
                        color: const Color(0xFF2086fd))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Energy burned",
                        image: "assets/images/kcal.jpeg",
                        data: activeEnergy != "null" ? "$activeEnergy cal" : "",
                        color: const Color(0xFFf77e7e))
                        ),
                        _logoutButton(),
              ],

            )
          ],
        ),
      ),
    );
  }
  Widget _logoutButton() {
    return IconButton(icon: FaIcon(FontAwesomeIcons.arrowRightArrowLeft), onPressed: () async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
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
        Image.asset(image, width: 70),
        Text(data),
      ],
    ),
  );
}

Textbutton({required Future Function() onPressed, required Text child}) {
}
}