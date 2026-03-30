import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget initNextButton(BuildContext context, VoidCallback callback) {
  final size = MediaQuery.of(context).size;
  return SafeArea(
    child: Container(
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.only(right: size.width * 0.05, bottom: size.height * 0.2),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          width: size.width * 0.35,
          height: 50.0,
          child: Material(
            color: AppColor.secondaryColor,
            borderRadius: BorderRadius.circular(25.0),
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Next",
                      style: TextStyle(
                        fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                        color: Colors.white,
                      ),
                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              onTap: callback,
            ),
          ),
        ),
      ),
    ),
  );
}
