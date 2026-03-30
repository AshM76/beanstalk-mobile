import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget noteCard(Size size, String note) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        child: Text(
          "Note",
          style: TextStyle(
              fontSize: AppFontSizes.contentSize - 1.0,
              color: AppColor.fourthColor,
              fontWeight: FontWeight.w600),
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: heightNotes(note),
        child: Stack(
          children: [
            Container(
              width: size.width * 0.70,
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              decoration: BoxDecoration(
                color: AppColor.thirdColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Center(
                child: Text(
                  note,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.contentSize,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              top: 5.0,
              left: 5.0,
              child: Image(
                color: AppColor.fifthColor,
                width: 17.5,
                image: AssetImage('assets/img/icon_arrow.png'),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

double heightNotes(String note) {
  if (note.length < 60) {
    return 80.0;
  } else if (note.length < 120) {
    return 120.0;
  } else {
    return 200.0;
  }
}
