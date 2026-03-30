import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_medication_model.dart';
import 'package:beanstalk_mobile/src/models/canna_productType_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget productTypeCard(Size size, ProductType productType) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        child: Text(
          "Product Type",
          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
        ),
      ),
      SizedBox(height: size.height * 0.005),
      Container(
        alignment: Alignment.center,
        height: size.height * 0.12,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(10.0)),
              child: Stack(
                children: [
                  Container(
                    width: size.width * 0.22,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.01),
                        Image(
                          color: Colors.white,
                          height: size.height * 0.05,
                          image: AssetImage('assets/img/medication/${AppData().iconProductType(productType.title!)}'),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: size.height * 0.01),
                        Container(
                          child: Center(
                            child: Text(
                              productType.title!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: productType.title!.length > 12 ? AppFontSizes.contentSmallSize : AppFontSizes.contentSmallSize + 1.5,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0.0,
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

Widget deliveryMethodCard(Size size, Medication medication) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        child: Text(
          "Delivery Method",
          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor),
        ),
      ),
      SizedBox(height: size.height * 0.005),
      Container(
        alignment: Alignment.center,
        height: size.height * 0.1,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(15.0)),
              child: Stack(
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.01),
                        Image(
                          color: Colors.white,
                          height: size.height * 0.045,
                          image: AssetImage('assets/img/medication/${AppData().iconMedication(medication.title!)}'),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: size.height * 0.01),
                        Center(
                          child: Text(
                            medication.title!,
                            style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0.0,
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
