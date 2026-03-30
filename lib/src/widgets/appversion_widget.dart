import 'package:flutter/material.dart';

Widget initAppVersion(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return Positioned(
    bottom: size.height * 0.035,
    right: size.width * 0.05,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "Staging", //"Test", //"Staging", //"Skining" //"Demo"
          style: TextStyle(color: Colors.grey[300], fontSize: 10.0),
        ),
        Text(
          "v.2.0.1", // Staging: "v.0.0.33", //"v.0.1.5a", //Android  "v.1.1.5" //ios
          style: TextStyle(color: Colors.grey[300], fontSize: 11.0),
        ),
      ],
    ),
  );
}
