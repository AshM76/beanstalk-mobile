import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import 'package:beanstalk_mobile/src/widgets/Onboarding/backButton_widget.dart';
import 'package:beanstalk_mobile/src/widgets/Onboarding/titleForm_widget.dart';

import 'package:beanstalk_mobile/src/widgets/Onboarding/backgroundPaint_widget.dart';

class OnboardingQuestionPage extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        initBackgroundPaint(context),
        _initProfileDataForm(context),
        backButton(context),
      ],
    ));
  }

  Widget _initProfileDataForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.04),
              initTitle("About You"),
              SizedBox(height: 50.0),
              _initQuestion(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initQuestion(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 250,
                child: Text(
                  "Have you ever used cannabis or CBD to treat your symptoms or conditions?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                  ),
                  textAlign: TextAlign.left,
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                Card(
                  elevation: 2.5,
                  color: AppColor.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                      child: SizedBox(
                        width: size.width * 0.35,
                        height: 50.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                            ),
                            textAlign: TextAlign.center,
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ),
                      ),
                      onTap: () {
                        print("::YES");
                        Navigator.pushNamed(context, 'onboarding_medication');
                      }),
                ),
                SizedBox(width: 10.0),
                Card(
                  elevation: 2.5,
                  color: AppColor.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                      child: SizedBox(
                        width: size.width * 0.35,
                        height: 50.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                            ),
                            textAlign: TextAlign.center,
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ),
                      ),
                      onTap: () {
                        print("::NO");
                        Navigator.pushNamed(context, 'onboarding_agree');
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
