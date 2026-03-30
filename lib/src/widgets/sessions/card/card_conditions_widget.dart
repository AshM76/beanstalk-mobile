import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../../../datas/app_data.dart';
import 'card_value_widthCard_widget.dart';

Widget primaryConditionsCard(Size size, List<Condition> conditions) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        child: Text(
          "Condition",
          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
        ),
      ),
      SizedBox(height: size.height * 0.005),
      Container(
        alignment: Alignment.topLeft,
        height: size.height * 0.1,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: conditions.length >= 3 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: conditions.length,
          itemBuilder: (BuildContext context, int index) {
            final condition = conditions[index];
            return Stack(
              children: [
                Container(
                  width: size.width * 0.22,
                  decoration: BoxDecoration(
                    color: AppColor.thirdColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.01),
                      Image(
                        color: AppColor.background,
                        height: size.height * 0.05,
                        image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: size.height * 0.005),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: Container(
                          height: size.height * 0.035,
                          child: Center(
                            child: Text(
                              condition.title!,
                              style:
                                  TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSmallSize + 1.5, fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image(
                        color: AppColor.fifthColor,
                        width: 12.0,
                        image: AssetImage('assets/img/icon_arrow.png'),
                        fit: BoxFit.contain,
                      ),
                    ],
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

Widget infoConditionsCard(Size size, List<Condition> secundaryConditions) {
  return Container(
    width: size.width * 0.45,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            "Secondary Condition(s)",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: size.height * 0.005),
        Container(
          width: size.width * 0.45,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: secundaryConditions.length,
            itemBuilder: (BuildContext context, int index) {
              final condition = secundaryConditions[index];
              return Stack(
                children: [
                  Container(
                    height: size.height * 0.027,
                    width: double.maxFinite,
                    margin: index == secundaryConditions.length - 1 ? null : EdgeInsets.only(bottom: size.width * 0.015),
                    decoration: BoxDecoration(
                      color: AppColor.thirdColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          condition.title!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    child: Image(
                      color: AppColor.fifthColor,
                      width: 10.0,
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
    ),
  );
}

Widget infoProductTypeCard(Size size, String? method, String strain) {
  return Container(
    width: size.width * 0.45,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            "Delivery Method",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: size.height * 0.0025),
        Stack(
          children: [
            Container(
              height: size.height * 0.027,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: AppColor.thirdColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    method == 'N/A' ? "-" : method!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              child: Image(
                color: AppColor.fifthColor,
                width: 10.0,
                image: AssetImage('assets/img/icon_arrow.png'),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.005),
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            "Strain Type",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: size.height * 0.0025),
        Stack(
          children: [
            Container(
              height: size.height * 0.027,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: AppColor.thirdColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    strain,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              child: Image(
                color: AppColor.fifthColor,
                width: 10.0,
                image: AssetImage('assets/img/icon_arrow.png'),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget infoProductCard(Size size, String brand, String name, String temperature, String? temperatureMeasurement) {
  return Container(
    width: size.width * 0.45,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            "Brand",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: size.height * 0.0025),
        Stack(
          children: [
            Container(
              height: size.height * 0.027,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: AppColor.thirdColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    brand,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              child: Image(
                color: AppColor.fifthColor,
                width: 10.0,
                image: AssetImage('assets/img/icon_arrow.png'),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.005),
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            "Product Name",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: size.height * 0.0025),
        Stack(
          children: [
            Container(
              height: size.height * 0.027,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: AppColor.thirdColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              child: Image(
                color: AppColor.fifthColor,
                width: 10.0,
                image: AssetImage('assets/img/icon_arrow.png'),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.0025),
        temperature.isNotEmpty
            ? Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "Temperature Setting",
                  style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
                ),
              )
            : Container(),
        temperature.isNotEmpty ? SizedBox(height: size.height * 0.0025) : Container(),
        temperature.isNotEmpty
            ? Stack(
                children: [
                  Container(
                    height: size.height * 0.027,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: AppColor.thirdColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          temperature + " " + temperatureMeasurement!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    child: Image(
                      color: AppColor.fifthColor,
                      width: 10.0,
                      image: AssetImage('assets/img/icon_arrow.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    ),
  );
}

Widget conditionsCard(Size size, String title, List<Condition> conditions, bool popup) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: 60.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: conditions.length >= 3 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: conditions.length,
          itemBuilder: (BuildContext context, int index) {
            final condition = conditions[index];
            return Stack(
              children: [
                Container(
                  width: valueWidthCard(size, conditions.length, popup),
                  decoration: BoxDecoration(
                    color: AppColor.thirdColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child:
                      // Center(
                      //   child: Text(
                      //     sympthom.title,
                      //     style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize + 1.0, fontWeight: FontWeight.w600),
                      //     textAlign: TextAlign.center,
                      //     maxLines: 2,
                      //   ),
                      // ),
                      Row(
                    children: [
                      Container(
                        width: size.width * 0.2,
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(5.0),
                        child: Image(
                          color: AppColor.background,
                          image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            condition.title!,
                            style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 5.0,
                  child: Image(
                    color: AppColor.fifthColor,
                    width: 15.0,
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
