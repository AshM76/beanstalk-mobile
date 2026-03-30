import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget initProfileDataEmptyField(BuildContext context, String title, VoidCallback callback) {
  final size = MediaQuery.of(context).size;
  return Align(
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: size.width * 0.75,
        height: 60.0,
        decoration: BoxDecoration(
          gradient: AppColor.secondaryGradient,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20.0,
              left: size.width * 0.035,
              child: Text(
                title,
                style: TextStyle(
                  color: AppColor.background,
                  fontSize: AppFontSizes.buttonSize + 5.0,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
            ),
            Positioned(
              top: 3.0,
              left: size.width * 0.025,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.1),
                  fontWeight: FontWeight.w900,
                  fontSize: AppFontSizes.buttonSize + 15.0,
                ),
              ),
            ),
            InkWell(
              child: Container(
                width: size.width * 0.75,
                padding: EdgeInsets.only(top: size.width * 0.04, bottom: size.width * 0.04, left: size.width * 0.6),
                child: Image(image: AssetImage('assets/img/icon_plusButton.png'), color: AppColor.background),
              ),
              onTap: callback,
            ),
          ],
        ),
      ),
    ),
  );
}
