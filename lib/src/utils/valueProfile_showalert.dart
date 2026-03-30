import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

void valueProfileShowAlert(
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
            height: 350.0,
            width: 300.0,
            child: Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 60.0,
                  alignment: Alignment.topCenter,
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
                      "Complete Profile",
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
                      height: 240.0,
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Please complete any unchecked items:",
                                style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              )),
                          SizedBox(height: 10.0),
                          Container(
                            width: 240.0,
                            child: Column(
                              children: [
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     Text(
                                //       "Email Validation",
                                //       style: TextStyle(
                                //           color: Colors.grey[600],
                                //           fontSize: AppFontSizes.contentSize,
                                //           fontWeight: FontWeight.w500),
                                //       textAlign: TextAlign.left,
                                //     ),
                                //     Expanded(child: Container()),
                                //     Icon(
                                //       _prefs.validateEmail
                                //           ? Icons.check_box_rounded
                                //           : Icons.crop_square_rounded,
                                //       size: 20.0,
                                //       color: _prefs.validateEmail
                                //           ? AppColor.secondaryColor
                                //           : AppColor.primaryColor,
                                //     ),
                                //   ],
                                // ),
                                // SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "First Name",
                                      style: TextStyle(color: Colors.grey[600], fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                    Expanded(child: Container()),
                                    Icon(
                                      _prefs.firstname != "" ? Icons.check_box_rounded : Icons.crop_square_rounded,
                                      size: 20.0,
                                      color: _prefs.firstname != "" ? AppColor.secondaryColor : AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Last Name",
                                      style: TextStyle(color: Colors.grey[600], fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                    Expanded(child: Container()),
                                    Icon(
                                      _prefs.lastname != "" ? Icons.check_box_rounded : Icons.crop_square_rounded,
                                      size: 20.0,
                                      color: _prefs.lastname != "" ? AppColor.secondaryColor : AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Username",
                                      style: TextStyle(color: Colors.grey[600], fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                    Expanded(child: Container()),
                                    Icon(
                                      _prefs.username != "" ? Icons.check_box_rounded : Icons.crop_square_rounded,
                                      size: 20.0,
                                      color: _prefs.username != "" ? AppColor.secondaryColor : AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Phone Number",
                                      style: TextStyle(color: Colors.grey[600], fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                    Expanded(child: Container()),
                                    Icon(
                                      _prefs.phonenumber != "" ? Icons.check_box_rounded : Icons.crop_square_rounded,
                                      size: 20.0,
                                      color: _prefs.phonenumber != "" ? AppColor.secondaryColor : AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Primary Conditions",
                                      style: TextStyle(color: Colors.grey[600], fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                    Expanded(child: Container()),
                                    Icon(
                                      _prefs.primaryConditions.length > 0 ? Icons.check_box_rounded : Icons.crop_square_rounded,
                                      size: 20.0,
                                      color: _prefs.primaryConditions.length > 0 ? AppColor.secondaryColor : AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Secondary Conditions",
                                      style: TextStyle(color: Colors.grey[600], fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                    Expanded(child: Container()),
                                    Icon(
                                      _prefs.secondaryConditions.length > 0 ? Icons.check_box_rounded : Icons.crop_square_rounded,
                                      size: 20.0,
                                      color: _prefs.secondaryConditions.length > 0 ? AppColor.secondaryColor : AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                                // SizedBox(height: 5.0),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     Text(
                                //       "Symptoms",
                                //       style: TextStyle(
                                //           color: Colors.grey[600],
                                //           fontSize: AppFontSizes.contentSize,
                                //           fontWeight: FontWeight.w500),
                                //       textAlign: TextAlign.left,
                                //     ),
                                //     Expanded(child: Container()),
                                //     Icon(
                                //       _prefs.symptoms.length > 0
                                //           ? Icons.check_box_rounded
                                //           : Icons.crop_square_rounded,
                                //       size: 20.0,
                                //       color: _prefs.symptoms.length > 0
                                //           ? AppColor.secondaryColor
                                //           : AppColor.primaryColor,
                                //     ),
                                //   ],
                                // ),
                                SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Consumption Methods",
                                      style: TextStyle(color: Colors.grey[600], fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                    Expanded(child: Container()),
                                    Icon(
                                      _prefs.medications.length > 0 ? Icons.check_box_rounded : Icons.crop_square_rounded,
                                      size: 20.0,
                                      color: _prefs.medications.length > 0 ? AppColor.secondaryColor : AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColor.background,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
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
                              "Ok",
                              style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w600),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      print("::Ok");
                      Navigator.pop(context);
                      // if (selectedRemember) {
                      //   _prefs.validateAge = true;
                      //   print("::Remember Me Save");
                      // }
                    },
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
