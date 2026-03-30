import 'package:flutter/material.dart';

import '../../ui/app_skin.dart';

Widget TitleQuestionForm(BuildContext context, String numberSection, String textSection) {
  final size = MediaQuery.of(context).size;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30.0,
          child: Center(
            child: Text(
              numberSection,
              style: TextStyle(
                fontSize: AppFontSizes.titleSize,
                fontFamily: AppFont.primaryFont,
                color: AppColor.primaryColor.withOpacity(0.3),
              ),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.01),
        Image(
          color: AppColor.fifthColor,
          width: AppFontSizes.contentSize,
          image: AssetImage('assets/img/icon_arrow.png'),
          fit: BoxFit.contain,
        ),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: Container(
            child: Text(
              textSection,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: TextStyle(
                fontSize: AppFontSizes.contentSize - 1.0,
                color: AppColor.content,
              ),
              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.05),
      ],
    ),
  );
}
