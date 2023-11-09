// // ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unnecessary_new, deprecated_member_use, use_build_context_synchronously, sort_child_properties_last, non_constant_identifier_names

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fitness/screens/login_screen.dart';
// import 'package:flutter/material.dart';
// // ignore: unused_import
// import 'package:fitness/helpers/firebase_auth.dart';

// class HomeScreen extends StatefulWidget {
//   final User user;

//   // ignore: use_key_in_widget_constructors, prefer_const_constructors_in_immutables
//   HomeScreen({required this.user});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late User _currentUser;

//   @override
//   void initState() {
//     _currentUser = widget.user;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.lightBlueAccent,
//         title: Text('Tis your Name and Email'),
//         centerTitle: true,
//       ),

//       body: WillPopScope(
//         onWillPop: () async {
//           final logout = await showDialog<bool>(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 title: new Text('Are you sure?'),
//                 content: new Text('Do you want to logout from this App'),
//                 actionsAlignment: MainAxisAlignment.spaceBetween,
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Logout();
//                     },
//                     child: const Text('Yes'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context, false);
//                     },
//                     child: const Text('No'),
//                   ),
//                 ],
//               );
//             },
//           );
//           return logout!;
//         },
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'NAME: ${_currentUser.displayName}',
//                 style: Theme.of(context).textTheme.bodyText1,
//               ),
//               SizedBox(height: 16.0),
//               Text(
//                 'EMAIL: ${_currentUser.email}',
//                 style: Theme.of(context).textTheme.bodyText1,
//               ),
//               SizedBox(height: 16.0),
//               Text(
//                 'PHONE NUMBER: ${_currentUser.phoneNumber}',
//                 style: Theme.of(context).textTheme.bodyText1,
//               ),
//               SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: () async {                  
//                   //ask if they want to logout first 
//                   //if yes, then logout
//                   //if no, then do nothing
//                   // ignore: unused_local_variable
//                   final logout = await showDialog<bool>(
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         title: new Text('Are you sure?'),
//                         content: new Text('Do you want to logout from this App'),
//                         actionsAlignment: MainAxisAlignment.spaceBetween,
//                         actions: [
//                           TextButton(
//                             onPressed: () {
//                               Logout();
//                             },
//                             child: const Text('Yes'),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context, false);
//                             },
//                             child: const Text('No'),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//                 child: const Text('Sign out'),
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(Colors.black),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )

//     );
//   }

//   Future<dynamic> Logout() async {

//     await FirebaseAuth.instance.signOut();

//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => LoginScreen(),
//       ),
//     );
//   }
// }