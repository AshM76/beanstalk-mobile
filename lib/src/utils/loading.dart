import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class ProgressDialog {
  final BuildContext context;
  ProgressDialog(this.context);

  void show() {
    showDialog(
      barrierDismissible: false,
      context: this.context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColor.secondaryColor,
              backgroundColor: AppColor.primaryColor,
            ),
          ),
        );
      },
    );
  }

  void dismiss() {
    Navigator.pop(context);
  }
}
