import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget backButton(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return SafeArea(
    child: Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding:
            EdgeInsets.only(right: size.width * 0.025, top: size.height * 0.01),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 30.0,
                  color: AppColor.secondaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                    color: AppColor.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
    ),
  );
}
