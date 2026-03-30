import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget showFieldContent(String content, double width, VoidCallback callback) {
  if (content.isEmpty) {
    return Container();
  }
  return Stack(
    children: [
      Container(
        width: width,
        height: 45.0,
        margin: const EdgeInsets.symmetric(vertical: 3.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColor.thirdColor.withOpacity(0.3),
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10.0)),
        child: Text(
          '$content',
          style: TextStyle(
            fontSize: AppFontSizes.contentSize + 1.0,
            color: Colors.white,
          ),
        ),
      ),
      Positioned(
        left: width - 15,
        child: InkWell(
          child: Container(
            height: 15.0,
            width: 15.0,
            decoration: BoxDecoration(
              color: AppColor.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.close,
              color: AppColor.secondaryColor,
              size: 14.0,
            ),
          ),
          onTap: callback,
        ),
      ),
    ],
  );
}
