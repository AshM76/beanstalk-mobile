import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backButton_widget.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backgroundPaint_widget.dart';

import '../../../datas/app_data.dart';
import '../../../utils/utils.dart';

class LumirOnboardingAgreePage extends StatefulWidget {
  @override
  _LumirOnboardingAgreePageState createState() => _LumirOnboardingAgreePageState();
}

class _LumirOnboardingAgreePageState extends State<LumirOnboardingAgreePage> {
  final _prefs = new UserPreference();

  bool? _acceptedLumirAgreement = false;
  bool? _acceptedAgreement = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        initBackgroundPaint(context),
        _initProfileAgreeForm(context),
        backButton(context),
      ],
    ));
  }

  Widget _initProfileAgreeForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              _initTitle(),
              _initAgreements(),
              SizedBox(height: size.height * 0.02),
              _initAcceptButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initTitle() {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            AppLogos.iconImg,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ),
          Container(
            height: 90.0,
            width: 250.0,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Informed Consent Form",
                style: TextStyle(
                  color: AppColor.fourthColor,
                  fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                  fontFamily: AppFont.primaryFont,
                ),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initAgreements() {
    final size = MediaQuery.of(context).size;
    return Material(
      elevation: 2.5,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: size.height * 0.6,
        width: size.width * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 15.0, left: 20),
              child: Text(
                "LUMIR CLINIC AND LUMIR MISSION MARKET RESEARCH STUDY WAIVER OF LIABILITY, INDEMNITY AND MEDICAL RELEASE :",
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: AppFontSizes.contentSmallSize + 1.5,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: size.height * 0.5,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.05),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Text(
                      AppData.dataTermsOfServices,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: AppFontSizes.contentSmallSize + 1.5,
                      ),
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: size.height * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        children: [
                          Checkbox(
                            side: BorderSide(color: AppColor.fourthColor, width: 2.0),
                            checkColor: Colors.white,
                            activeColor: AppColor.secondaryColor,
                            value: _acceptedAgreement,
                            onChanged: (value) {
                              setState(() {
                                _acceptedAgreement = value;
                              });
                            },
                          ),
                          Text(
                            "I've read and agree",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: AppFontSizes.contentSize - 2.0,
                              height: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Divider(height: 5.0, color: AppColor.primaryColor),
                    _initLumirAgreements(),
                    SizedBox(height: size.height * 0.01),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initLumirAgreements() {
    final size = MediaQuery.of(context).size;
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(0.0),
      child: Container(
        width: size.width * 0.70,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Checkbox(
              side: BorderSide(color: AppColor.fourthColor, width: 2.0),
              checkColor: Colors.white,
              activeColor: AppColor.secondaryColor,
              value: _acceptedLumirAgreement,
              onChanged: (value) {
                setState(() {
                  _acceptedLumirAgreement = value;
                });
              },
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "I've read and agree to Lumir's",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.contentSize - 2.0,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    child: Text(
                      "Privacy policy and terms of service",
                      style: TextStyle(
                        fontSize: AppFontSizes.contentSize - 2.0,
                        color: AppColor.fourthColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    onTap: () {
                      showAlertMessageAction(context, "Policy and Terms", 'Privacy policy and term of service', "Done", () {
                        _prefs.validateAge = false;
                        Navigator.pop(context);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initAcceptButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            width: size.width * 0.75,
            height: 50.0,
            child: Material(
              color: (_acceptedAgreement! && _acceptedLumirAgreement!) ? AppColor.secondaryColor : AppColor.content.withOpacity(0.4),
              borderRadius: BorderRadius.circular(15.0),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Accept",
                        style: TextStyle(
                          fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                          color: (_acceptedAgreement! && _acceptedLumirAgreement!) ? Colors.white : Colors.grey[200],
                          fontWeight: FontWeight.bold,
                        ),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.check,
                        size: 30.0,
                        color: (_acceptedAgreement! && _acceptedLumirAgreement!) ? Colors.white : AppColor.content.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  if (_acceptedAgreement! && _acceptedLumirAgreement!) {
                    _prefs.agreementAccepted = true;
                    Navigator.pushNamed(context, 'onboarding_profile');
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
