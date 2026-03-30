import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../../../models/canna_condition_model.dart';
import 'cardSmall_value_widthCard_widget.dart';

Widget conditionsCardSmall(Size size, List<Condition> conditions, bool isActive) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(bottom: size.height * 0.003),
        child: Text(
          "Conditions",
          style: TextStyle(
            fontSize: size.width * 0.032,
            color: isActive ? AppColor.fourthColor : AppColor.content,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        height: 40.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: conditions.length >= 2 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: conditions.length,
          itemBuilder: (BuildContext context, int index) {
            final sympthom = conditions[index];
            return Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 2.5),
                  width: valueWidthCardSmall(size, conditions.length, isActive),
                  decoration: BoxDecoration(
                    color: isActive ? AppColor.thirdColor.withOpacity(0.3) : AppColor.content.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(size.width * 0.035),
                  ),
                  child: Center(
                    child: Text(
                      sympthom.title!,
                      style: TextStyle(
                          color: isActive ? Colors.white : AppColor.content,
                          fontSize: AppFontSizes.contentSmallSize + 1.5,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ),
                Positioned(
                  top: 2.5,
                  child: Image(
                    color: AppColor.fifthColor,
                    width: 12.0,
                    image: AssetImage('assets/img/icon_arrow.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ],
  );
}
