import 'package:flutter/material.dart';

import '../../ui/app_skin.dart';

Widget TitleSectionSession(BuildContext context, String textSection) {
  final size = MediaQuery.of(context).size;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image(
        color: AppColor.fifthColor,
        width: AppFontSizes.subTitleSize,
        image: AssetImage('assets/img/icon_arrow.png'),
        fit: BoxFit.contain,
      ),
      SizedBox(width: size.width * 0.02),
      Text(
        textSection,
        style: TextStyle(
          fontSize: AppFontSizes.subTitleSize,
          color: AppColor.secondaryColor,
          fontFamily: AppFont.primaryFont,
        ),
        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
      ),
    ],
  );
}

Widget TitleInternalSectionSession(BuildContext context, String textSection, bool requiredField) {
  final size = MediaQuery.of(context).size;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image(
        color: AppColor.fifthColor,
        width: AppFontSizes.contentSize,
        image: AssetImage('assets/img/icon_arrow.png'),
        fit: BoxFit.contain,
      ),
      SizedBox(width: size.width * 0.02),
      Text(
        textSection,
        style: TextStyle(
          fontSize: AppFontSizes.contentSize,
          color: AppColor.content,
        ),
        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
      ),
      requiredField
          ? Text(
              " *",
              style: TextStyle(
                fontSize: AppFontSizes.contentSize,
                fontFamily: AppFont.primaryFont,
                color: AppColor.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            )
          : Container(),
    ],
  );
}
