import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget productNameCardSmall(
    Size size, String title, String name, bool isActive) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.only(
            top: size.height * 0.006, bottom: size.height * 0.003),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: size.width * 0.032,
            color: isActive ? AppColor.fourthColor : AppColor.content,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: 40.0,
        margin: EdgeInsets.only(right: 2.5),
        child: Stack(
          children: [
            Container(
              width: size.width * 0.60,
              decoration: BoxDecoration(
                  color: isActive
                      ? AppColor.thirdColor.withOpacity(0.3)
                      : AppColor.content.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(size.width * 0.035)),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      name,
                      style: TextStyle(
                          color: isActive ? Colors.white : AppColor.content,
                          fontSize: AppFontSizes.contentSmallSize,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500),
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
                width: 12.0,
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
