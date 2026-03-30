import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget profileProgressBar(BuildContext context, int value) {
  final size = MediaQuery.of(context).size;
  return Container(
    width: double.infinity,
    height: 30.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size.width * 0.025),
      color: AppColor.primaryColor.withOpacity(0.2),
      border: Border.all(color: Colors.white.withOpacity(0.7)),
    ),
    child: Stack(
      children: [
        TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.25, end: value / 100),
            duration: Duration(milliseconds: 1),
            builder: (context, value, _) {
              return LayoutBuilder(
                  builder: (context, constraints) => Container(
                      width: constraints.maxWidth * value,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * 0.025),
                        color: AppColor.fourthColor.withOpacity(0.7),
                      )));
            }),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Profile Data",
                style: TextStyle(
                  fontSize: AppFontSizes.contentSmallSize,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                "$value%",
                style: TextStyle(fontSize: AppFontSizes.contentSmallSize + 1.5, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            )
          ],
        )
      ],
    ),
  );
}
