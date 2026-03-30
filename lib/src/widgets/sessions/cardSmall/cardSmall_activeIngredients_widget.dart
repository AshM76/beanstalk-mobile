import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/canna_cannabinoid_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget activeIngredientsCardSmall(Size size, List<Cannabinoid> cannabinoids, String? measurement) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(top: size.height * 0.003, bottom: size.height * 0.003),
        child: Text(
          "Active Ingredients",
          style: TextStyle(fontSize: size.width * 0.032, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: 40.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: cannabinoids.length >= 2 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: cannabinoids.length,
          itemBuilder: (BuildContext context, int index) {
            final cannabinoid = cannabinoids[index];
            return Stack(
              children: [
                Container(
                  width: cannabinoids.length <= 2 ? size.width * 0.17 : size.width * 0.15,
                  margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: AppColor.thirdColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cannabinoid.title!,
                          style: TextStyle(
                            color: AppColor.background,
                            fontSize: size.width * 0.027,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // SizedBox(height: 2.5),
                        Text(
                          cannabinoid.value == "" ? "-" : "${cannabinoid.value} $measurement",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.02,
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
