import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget initTitle(String title) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          AppLogos.iconImg,
          width: 40.0,
          height: 40.0,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 1.0),
        Text(
          title,
          style: TextStyle(
            color: AppColor.fourthColor,
            fontSize: AppFontSizes.titleSize + 10.0,
            fontFamily: AppFont.primaryFont,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    ),
  );
}
