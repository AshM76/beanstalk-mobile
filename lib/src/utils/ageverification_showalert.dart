import 'dart:io';

import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';

void ageVerificationShowAlert(
  BuildContext context,
  bool selectedRemember,
) {
  final _prefs = new UserPreference();
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 400),
    context: context,
    pageBuilder: (_, __, ___) {
      return StatefulBuilder(builder: (context, setState) {
        return Dialog(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            height: 220.0,
            width: 300.0,
            child: Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 60.0,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Age Verification",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppFontSizes.subTitleSize + 2.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 80.0,
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Are you at least 21 years old?",
                              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Remember Me",
                                style: TextStyle(color: Colors.grey[600], fontSize: AppFontSizes.contentSmallSize, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.left,
                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                              ),
                              SizedBox(width: 10.0),
                              InkWell(
                                child: Icon(
                                  selectedRemember ? Icons.check_box_rounded : Icons.crop_square_rounded,
                                  size: 22.0,
                                  color: selectedRemember ? AppColor.secondaryColor : AppColor.primaryColor,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (selectedRemember) {
                                      selectedRemember = false;
                                      print(":false");
                                    } else {
                                      selectedRemember = true;
                                      print(":true");
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
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
                                    "Yes",
                                    style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            print("::YES");
                            Navigator.pop(context);
                            if (selectedRemember) {
                              _prefs.validateAge = true;
                              print("::Remember Me Save");
                            }
                          },
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
                                    "No",
                                    style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            print("::NO");
                            Navigator.pop(context);
                            showAlertMessage(context, "You must be 21 years old to use Beanstalk", () {
                              exit(0);
                            });
                            //SystemNavigator.pop(); //android
                            // exit(0); // ios
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
      });
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}
