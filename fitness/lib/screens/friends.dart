//friends page for the app, after someone clicks on the friends tab on bottom navigation bar

// import 'package:fitness/screens/friends.dart';
import 'package:flutter/material.dart';
import 'package:fitness/screens/home.dart';

// import 'package:fitness/screens/profile.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Friends'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Friends'),
          ],
        ),
      ),
    );
  }
}