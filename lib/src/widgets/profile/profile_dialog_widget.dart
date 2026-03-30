import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

void showProfileDialog(BuildContext context, String title, double height, Widget content, VoidCallback callback) {
  Dialog fancyDialog = Dialog(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Container(
      height: 150.0 + height,
      width: 300.0,
      child: Stack(
        children: <Widget>[
          //TOP
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.secondaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 5.0,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
          ),
          //CENTER
          Align(
            alignment: Alignment.center,
            child: content,
          ),
          //BOTTOM
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: InkWell(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColor.background,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Divider(
                            thickness: 1.0,
                            height: 0.0,
                            color: AppColor.primaryColor,
                          ),
                          SizedBox(height: 15.0),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Done",
                              style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w800),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: callback,
                  ),
                ),
                Container(
                  width: 1.0,
                  height: 63.0,
                  color: AppColor.primaryColor,
                ),
                Flexible(
                  flex: 2,
                  child: InkWell(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColor.background,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Divider(
                            thickness: 1.0,
                            height: 0.0,
                            color: AppColor.primaryColor,
                          ),
                          SizedBox(height: 15.0),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w400),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  showDialog(context: context, builder: (BuildContext context) => fancyDialog);
}
