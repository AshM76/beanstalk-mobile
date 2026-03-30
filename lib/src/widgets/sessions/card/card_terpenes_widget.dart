import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/canna_terpene_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import 'card_value_widthCard_widget.dart';

Widget terpenesCard(Size size, List<Terpene> terpenes, String? measurement, bool popup) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: size.height * 0.005),
      Container(
        child: Text(
          "Terpene(s)",
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
          physics: terpenes.length >= 3 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: terpenes.length,
          itemBuilder: (BuildContext context, int index) {
            final terpene = terpenes[index];
            return Stack(
              children: [
                Container(
                  width: valueWidthCard(size, terpenes.length, popup),
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
                          terpene.title!,
                          style: TextStyle(
                            color: AppColor.background,
                            fontSize: AppFontSizes.contentSize,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.5),
                        Text(
                          terpene.value == "" || terpene.value == "-" ? "-" : "${terpene.value} $measurement",
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
