import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/canna_medication_model.dart';

import 'package:beanstalk_mobile/src/services/authentication/auth_service.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/Onboarding/backButton_widget.dart';
import 'package:beanstalk_mobile/src/widgets/Onboarding/titleForm_widget.dart';

import 'package:beanstalk_mobile/src/widgets/Onboarding/backgroundPaint_widget.dart';

// ignore: must_be_immutable
class OnboardingResumePage extends StatelessWidget {
  final authServices = AuthServices();
  final _prefs = new UserPreference();
  List<Condition> conditions = [];
  List<Medication> medications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        initBackgroundPaint(context),
        _initResumeForm(context),
        backButton(context),
      ],
    ));
  }

  _initResumeForm(BuildContext context) {
    final size = MediaQuery.of(context).size;

    conditions = [];
    _prefs.primaryConditions.forEach((condition) {
      Map<String, dynamic> temp = jsonDecode(condition);
      Condition tempCondition = Condition.fromJson(temp);
      conditions.add(tempCondition);
    });

    medications = [];
    _prefs.medications.forEach((medication) {
      Map<String, dynamic> temp = jsonDecode(medication);
      Medication tempMedication = Medication.fromJson(temp);
      medications.add(tempMedication);
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.04),
              initTitle("Summary"),
              _initName(context),
              _initUserName(context),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  _initInfo(context, "Gender", '${_prefs.gender}', size.width * 0.275),
                  SizedBox(width: size.width * 0.025),
                  _initInfo(context, "Date of birth", '${_prefs.age}', size.width * 0.4),
                ],
              ),
              _initPhoneNumber(context),
              _initConditions(context),
              _initPreferences(context),
              SizedBox(height: size.height * 0.02),
              _initCompleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initInfo(BuildContext context, String title, String content, double width) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: width,
      height: 60.0,
      margin: EdgeInsets.symmetric(vertical: size.height * 0.002),
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: AppColor.thirdColor.withOpacity(0.3), border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColor.fourthColor, fontSize: AppFontSizes.contentSmallSize),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          SizedBox(height: 2.0),
          Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.contentSize + 2.5,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _initName(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_prefs.firstname.isEmpty) {
      return Container();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.01),
          _initInfo(context, "Name", '${_prefs.firstname} ${_prefs.lastname}', size.width * 0.7),
        ],
      );
    }
  }

  Widget _initUserName(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_prefs.username.isEmpty) {
      return Container();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.01),
          _initInfo(context, "Username", _prefs.username, size.width * 0.7),
        ],
      );
    }
  }

  Widget _initPhoneNumber(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_prefs.phonenumber.isEmpty) {
      return Container();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.01),
          _initInfo(context, "Phone number", '${_prefs.phonenumber}', size.width * 0.7),
        ],
      );
    }
  }

  Widget _initConditions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (conditions.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.01),
          Text(
            "Your Symptoms or Conditions",
            style: TextStyle(color: AppColor.fourthColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w300),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          SizedBox(height: size.height * 0.005),
          Container(
            margin: EdgeInsets.only(right: 50.0),
            height: 110.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: conditions.length,
              itemBuilder: (BuildContext context, int index) {
                final condition = conditions[index];
                return Container(
                  width: 80.0,
                  padding: EdgeInsets.all(5.0),
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  decoration: BoxDecoration(
                      color: AppColor.thirdColor.withOpacity(0.3),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        color: Colors.white.withOpacity(0.8),
                        height: 50.0,
                        width: 50.0,
                        image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 7.5),
                      Container(
                        height: 20.0,
                        width: 70.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            condition.title!,
                            style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _initPreferences(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (medications.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.01),
          Text(
            "Your Preferences",
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            style: TextStyle(color: AppColor.fourthColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w300),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: size.height * 0.01),
          Container(
            margin: EdgeInsets.only(right: 50.0),
            height: 140.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: medications.length,
              itemBuilder: (BuildContext context, int index) {
                final medication = medications[index];
                return Container(
                  width: 80.0,
                  padding: EdgeInsets.all(5.0),
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  decoration: BoxDecoration(
                      color: AppColor.thirdColor.withOpacity(0.3),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image(
                      color: Colors.white.withOpacity(0.8),
                      height: 50.0,
                      width: 50.0,
                      image: AssetImage('assets/img/medication/${AppData().iconMedication(medication.title!)}'),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      height: 20.0,
                      width: 80.0,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          medication.title!,
                          style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Column(
                      children: [
                        Divider(height: 7.5, color: AppColor.fourthColor),
                        Text(
                          medication.preference,
                          style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSmallSize - 1.0),
                        ),
                        SizedBox(height: 2.5),
                        Text(
                          medication.experience,
                          style: TextStyle(color: AppColor.fourthColor, fontSize: AppFontSizes.contentSmallSize - 1.0),
                        ),
                      ],
                    ),
                  ]),
                );
              },
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _initCompleteButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        alignment: Alignment.bottomRight,
        padding: EdgeInsets.only(right: size.width * 0.05, bottom: size.height * 0.2),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(25.0),
          child: Container(
            width: size.width * 0.45,
            height: 50.0,
            child: Material(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(25.0),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.038),
                      child: Text(
                        "Complete",
                        style: TextStyle(
                          fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                          color: Colors.white,
                        ),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 30.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                onTap: () => _complete(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _complete(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    if (_prefs.demoVersion) {
      progressDialog.dismiss();
      showAlertMessageAction(context, "Verify your email",
          'We just sent you a verification email, please click the link to verify your email and complete your sign up', 'OK', () {
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, 'navigation');
      });
    } else {
      try {
        Map infoResponse = await authServices.signIn(_prefs.email, _prefs.password);
        if (infoResponse['ok']) {
          progressDialog.dismiss();
          showAlertMessageAction(context, "Verify your email",
              'We just sent you a verification email, please click the link to verify your email and complete your sign up', 'OK', () {
            Navigator.of(context).pop();
            Navigator.pushReplacementNamed(context, 'navigation');
          });
        } else {
          progressDialog.dismiss();
          showAlertMessage(context, infoResponse['message'], () {
            Navigator.pop(context);
          });
        }
      } catch (e) {
        showAlertMessage(context, "A network error occurred", () {
          Navigator.pop(context);
        });
        throw e;
      }
    }
  }
}
