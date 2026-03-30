import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget productNameCard(Size size, String title, String name) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
              fontSize: AppFontSizes.contentSize - 1.0,
              color: AppColor.fourthColor,
              fontWeight: FontWeight.w600),
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: 70,
        child: Stack(
          children: [
            Container(
              width: size.width * 0.70,
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              decoration: BoxDecoration(
                  color: AppColor.thirdColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(18.0)),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: AppFontSizes.contentSize + 1.0,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 5.0,
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
