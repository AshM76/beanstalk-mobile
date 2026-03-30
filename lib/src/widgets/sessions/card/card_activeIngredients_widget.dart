import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/canna_cannabinoid_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import 'card_value_widthCard_widget.dart';

Widget activeIngredientsCard(Size size, List<Cannabinoid> cannabinoids, String? measurement, bool popup) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        child: Text(
          "Active Ingredients",
          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
        ),
      ),
      SizedBox(height: size.height * 0.005),
      Container(
        alignment: Alignment.center,
        height: 65.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: cannabinoids.length >= 3 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: cannabinoids.length,
          itemBuilder: (BuildContext context, int index) {
            final cannabinoid = cannabinoids[index];
            return Stack(
              children: [
                Container(
                  width: valueWidthCard(size, cannabinoids.length, popup),
                  margin: EdgeInsets.only(right: size.width * 0.015),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cannabinoid.title!,
                          style: TextStyle(
                            color: AppColor.background,
                            fontSize: AppFontSizes.contentSize,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.5),
                        Text(
                          cannabinoid.value == "" || cannabinoid.value == "-" ? "-" : "${cannabinoid.value} $measurement",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: measurement!.length > 5 ? 12.5 : 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
            );
          },
        ),
      ),
    ],
  );
}
