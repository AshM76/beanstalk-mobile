import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget initProfileInfoEmptyField(BuildContext context, String icon, String title, VoidCallback callback) {
  final size = MediaQuery.of(context).size;
  return Align(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size.width * 0.7,
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Image(
                  color: AppColor.content.withOpacity(0.25),
                  image: AssetImage('assets/img/profile/icon_profile_$icon.png'),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: size.width * 0.01),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.015),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColor.content.withOpacity(0.5),
                          fontSize: AppFontSizes.contentSize - 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.025),
            ],
          ),
        ),
        SizedBox(width: size.width * 0.02),
        Card(
          elevation: 1.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            child: SizedBox(
              width: size.width * 0.12,
              height: 55.0,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 2.5),
                    Image(
                      height: 25.0,
                      width: 25.0,
                      image: AssetImage('assets/img/icon_plusButton.png'),
                      fit: BoxFit.contain,
                      color: AppColor.thirdColor,
                    ),
                    SizedBox(height: 2.0),
                    Container(
                      height: 15.0,
                      width: 37.5,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.grey[600], fontSize: 10.0, fontWeight: FontWeight.w300),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: callback,
          ),
        ),
      ],
    ),
  );
}
