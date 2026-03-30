import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_productType_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget productTypeCardSmall(Size size, ProductType productType, bool isActive) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(top: size.height * 0.003, bottom: size.height * 0.003),
        child: Text(
          "Product Type",
          style: TextStyle(
            fontSize: size.width * 0.032,
            color: isActive ? AppColor.fourthColor : AppColor.content,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: 42.5,
        child: Stack(
          children: [
            Container(
              width: size.width * 0.60,
              decoration: BoxDecoration(
                  color: isActive ? AppColor.thirdColor.withOpacity(0.3) : AppColor.content.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(size.width * 0.035)),
              child: Stack(
                children: [
                  Container(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image(
                        color: isActive ? Colors.white : AppColor.content,
                        height: 35.0,
                        width: 35.0,
                        image: AssetImage('assets/img/medication/${AppData().iconProductType(productType.title!)}'),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Center(
                        child: Text(
                          productType.title!,
                          style: TextStyle(
                              color: isActive ? Colors.white : AppColor.content,
                              fontSize: AppFontSizes.contentSmallSize + 1.5,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]),
                  ),
                ],
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
        ),
      ),
    ],
  );
}
