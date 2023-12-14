import 'package:flutter/material.dart';

class AppFont {
  static const String montserrat = 'Montserrat';
  static const String nunito = 'Nunito';
}

class HealthCard extends StatelessWidget {
  @override
  


  Widget build(BuildContext context) {
    Color color = Colors.blue; // Define the color variable
    String title = 'Example Title'; // Define the title variable
    String image = 'assets/images/example.png'; // Define the image variable
    String data = 'Example Data'; // Define the data variable

    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color, // Use the defined color variable
        borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Column(
            children: [
              Image.asset(image, width: 70), // Use the defined image variable
            ],
          ),
          Text(data), // Use the defined data variable
        ],
      ),
    );
  }
}