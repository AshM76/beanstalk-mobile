import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

void showAlertMessage(BuildContext context, String? message, VoidCallback callback) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 300),
    context: context,
    pageBuilder: (_, __, ___) {
      return customDialog(context, message!, "OK", callback);
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

void showAlertLongMessage(BuildContext context, String message, VoidCallback callback) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 300),
    context: context,
    pageBuilder: (_, __, ___) {
      return customLongDialog(context, message, "OK", callback);
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

void showAlertMessageAction(BuildContext context, String title, String message, String button, VoidCallback callback) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 300),
    context: context,
    pageBuilder: (_, __, ___) {
      return customActionDialog(context, title, message, button, callback);
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

void showAlertMessageTwoAction(BuildContext context, double height, String title, String message, String firstButton, String secondButton,
    VoidCallback firstCallback, VoidCallback secondCallback) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 300),
    context: context,
    pageBuilder: (_, __, ___) {
      return customTwoActionDialog(context, height, title, message, firstButton, secondButton, firstCallback, secondCallback);
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

Widget customDialog(BuildContext context, String message, String button, VoidCallback callback) {
  return Dialog(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      height: 170.0,
      width: 200.0,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              alignment: Alignment.center,
              height: 90.0,
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10.0, right: 10.0),
              child: Text(
                message,
                style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: AppColor.primaryGradient,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    button,
                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w600),
                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                  ),
                ),
              ),
              onTap: callback,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget customLongDialog(BuildContext context, String message, String button, VoidCallback callback) {
  return Dialog(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      height: 210.0,
      width: 210.0,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              alignment: Alignment.center,
              height: 140.0,
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10.0, right: 10.0),
              child: Text(
                message,
                style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: AppColor.primaryGradient,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    button,
                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w600),
                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                  ),
                ),
              ),
              onTap: callback,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget customActionDialog(BuildContext context, String title, String message, String button, VoidCallback callback) {
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
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.subTitleSize + 2.5,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 140.0,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              child: Container(
                width: double.infinity,
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
                    SizedBox(height: 12.5),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        button,
                        style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w600),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: callback,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget customTwoActionDialog(BuildContext context, double height, String title, String message, String firstbutton, String secondbutton,
    VoidCallback firstCallback, VoidCallback secondCallback) {
  return Dialog(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Container(
      height: height,
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
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.subTitleSize + 2.5,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  alignment: Alignment.center,
                  height: height / 2,
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10.0, right: 10.0),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
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
                              firstbutton,
                              style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w600),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: firstCallback,
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
                              secondbutton,
                              style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w600),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: secondCallback,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
