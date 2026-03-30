import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_additional_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backButton_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/titleForm_widget.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backgroundPaint_widget.dart';

import '../../../widgets/onboarding/actionCardAddCondition_widget.dart';
import '../../../widgets/onboarding/nextButton_widget.dart';
import '../../../widgets/profile/lumir_study/lummir_selectCondition_widget.dart';
import '../../../widgets/profile/lumir_study/lummir_selectSecondaryCondition_widget.dart';

class LumirOnboardingConditionPage extends StatefulWidget {
  @override
  _LumirOnboardingConditionPageState createState() => _LumirOnboardingConditionPageState();
}

class _LumirOnboardingConditionPageState extends State<LumirOnboardingConditionPage> {
  final _prefs = new UserPreference();

  List<Condition> primaryConditionsSelected = [];
  List<Condition> secondaryConditionsSelected = [];

  List<Additional> additionalConditionsList = [];
  List<Additional> additionalConditionsSelected = [];

  @override
  void initState() {
    super.initState();
    additionalConditionsList = AppData.dataAdditionals;
    additionalConditionsList.forEach((c) {
      c.isSelected = false;
    });
    AppData.dataConditions.forEach((c) {
      c.isSelected = false;
    });
    _prefs.primaryConditions = [];
    _prefs.secondaryConditions = [];
    _prefs.additionalConditions = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: AppColor.background,
      child: Stack(
        children: <Widget>[
          initBackgroundPaint(context),
          _initConditionsForm(context),
          backButton(context),
        ],
      ),
    ));
  }

  Widget _initConditionsForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              initTitle("Therapeutic Information"),
              SizedBox(height: size.height * 0.01),
              _initConditions(),
              SizedBox(height: size.height * 0.01),
              _initAdditional(context),
              SizedBox(height: size.height * 0.02),
              initNextButton(context, () {
                _next(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initConditions() {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 290,
            child: Row(
              children: [
                Text(
                  "Please Select Your Primary Condition",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize,
                  ),
                  textAlign: TextAlign.left,
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
                Text(
                  " *",
                  style: TextStyle(
                    fontSize: AppFontSizes.contentSize,
                    fontFamily: AppFont.primaryFont,
                    color: AppColor.fourthColor,
                    fontWeight: FontWeight.w700,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                )
              ],
            ),
          ),
          primaryConditionsSelected.length > 0
              ? Container(
                  height: size.height * 0.18,
                  width: size.width * 0.8,
                  child: Scrollbar(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.01,
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: primaryConditionsSelected.length,
                        itemBuilder: (BuildContext context, int index) {
                          final _conditionPrimary = primaryConditionsSelected[index];
                          return _conditionPrimaryCards(_conditionPrimary);
                        },
                      ),
                    ),
                  ),
                )
              : ActionCardAddCondition("add", size, () {
                  showSelectConditionDialog(context, primaryConditionsSelected, setState, ((primaryConditions) {
                    primaryConditionsSelected = primaryConditions;
                    secondaryConditionsSelected = [];
                    _prefs.secondaryConditions.forEach((condition) {
                      Map<String, dynamic> temp = jsonDecode(condition);
                      Condition tempCondition = Condition.fromJson(temp);
                      primaryConditionsSelected.add(tempCondition);
                    });
                    secondaryConditionsSelected.removeWhere((tempCondition) => tempCondition.title == primaryConditionsSelected[0].title);
                    Navigator.of(context).pop();
                    setState(() {});
                  }));
                }),
          Container(
            width: 280,
            child: Text(
              "Please Select One or More Secondary Conditions",
              style: TextStyle(
                color: Colors.white,
                fontSize: AppFontSizes.subTitleSize,
              ),
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            ),
          ),
          secondaryConditionsSelected.length > 0
              ? Container(
                  height: size.height * 0.16,
                  width: size.width * 0.8,
                  child: Scrollbar(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.01,
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: secondaryConditionsSelected.length,
                        itemBuilder: (BuildContext context, int index) {
                          final _conditionSecondary = secondaryConditionsSelected[index];
                          return _conditionSecondaryCards(_conditionSecondary, false);
                        },
                      ),
                    ),
                  ),
                )
              : ActionCardAddCondition("add", size, () {
                  showSelectSecondaryConditionDialog(context, primaryConditionsSelected, secondaryConditionsSelected, setState,
                      ((secondaryConditions) {
                    secondaryConditionsSelected = secondaryConditions;
                    Navigator.of(context).pop();
                    setState(() {});
                  }));
                }),
        ],
      ),
    );
  }

  Widget _conditionPrimaryCards(Condition condition) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.27,
      child: GestureDetector(
        onTap: () {
          showSelectConditionDialog(context, primaryConditionsSelected, setState, ((primaryConditions) {
            primaryConditionsSelected = primaryConditions;
            secondaryConditionsSelected = [];
            _prefs.secondaryConditions.forEach((condition) {
              Map<String, dynamic> temp = jsonDecode(condition);
              Condition tempCondition = Condition.fromJson(temp);
              primaryConditionsSelected.add(tempCondition);
            });
            secondaryConditionsSelected.removeWhere((tempCondition) => tempCondition.title == primaryConditionsSelected[0].title);
            Navigator.of(context).pop();
            setState(() {});
          }));
        },
        child: Card(
          elevation: 2.5,
          color: condition.isSelected ? AppColor.secondaryColor : AppColor.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              width: 2.0,
              color: condition.isSelected ? AppColor.background : Colors.transparent,
            ),
          ),
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.01),
                Image(
                  color: condition.isSelected ? AppColor.background : AppColor.primaryColor,
                  width: size.width * 0.2,
                  height: size.height * 0.09,
                  image: AssetImage('assets/img/condition/${condition.icon}'),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: size.height * 0.005),
                Container(
                  width: size.width * 0.2,
                  height: size.height * 0.04,
                  child: Center(
                    child: Text(
                      condition.title!,
                      style: TextStyle(
                          color: condition.isSelected ? AppColor.background : AppColor.content,
                          fontSize: condition.title!.length > 12 ? size.width * 0.03 : size.width * 0.037,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _conditionSecondaryCards(Condition condition, bool primary) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.23,
      child: GestureDetector(
        onTap: () {
          showSelectSecondaryConditionDialog(context, primaryConditionsSelected, secondaryConditionsSelected, setState, ((secondaryConditions) {
            secondaryConditionsSelected = secondaryConditions;
            Navigator.of(context).pop();
            setState(() {});
          }));
        },
        child: Card(
          elevation: 2.5,
          color: condition.isSelected ? AppColor.secondaryColor : AppColor.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              width: 2.0,
              color: condition.isSelected ? AppColor.background : Colors.transparent,
            ),
          ),
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.01),
                Image(
                  color: condition.isSelected ? AppColor.background : AppColor.primaryColor,
                  width: size.width * 0.15,
                  height: size.height * 0.075,
                  image: AssetImage('assets/img/condition/${condition.icon}'),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: size.height * 0.005),
                Container(
                  width: size.width * 0.2,
                  height: size.height * 0.04,
                  child: Center(
                    child: Text(
                      condition.title!,
                      style: TextStyle(
                          color: condition.isSelected ? AppColor.background : AppColor.content,
                          fontSize: condition.title!.length > 12 ? size.width * 0.025 : size.width * 0.033,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _initAdditional(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "In addition to the above conditions, do you have any of the following?",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            maxLines: 2,
          ),
          SizedBox(height: size.height * 0.01),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: additionalConditionsList.length,
            itemBuilder: (BuildContext context, int index) {
              final additional = additionalConditionsList[index];
              return StatefulBuilder(builder: (context, setState) {
                return Card(
                  elevation: 2.5,
                  color: additional.isSelected ? AppColor.secondaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.5),
                    side: BorderSide(width: 1.5, color: additional.isSelected ? AppColor.background : Colors.transparent),
                  ),
                  child: InkWell(
                    child: Container(
                      height: size.height * 0.0475,
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: size.height * 0.005),
                            Text(
                              additional.title!,
                              style: TextStyle(
                                  color: additional.isSelected ? AppColor.background : AppColor.content,
                                  fontSize: AppFontSizes.contentSize - 2.5,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (additional.isSelected) {
                          additional.isSelected = false;
                          additionalConditionsSelected.removeWhere((e) => e.title == additional.title);
                        } else {
                          additional.isSelected = true;
                          additionalConditionsSelected.add(additional);
                        }
                      });
                    },
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  bool _validateConditions() {
    if (primaryConditionsSelected.length <= 0) {
      showAlertMessage(context, "Please Select at least one primary condition", () {
        Navigator.pop(context);
      });
      return false;
    }
    //  else if (additionalConditionsSelected.length <= 0) {
    //   showAlertMessage(context, "Please select additional condition", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // }
    List<String> conditionPrimaryEncoded = primaryConditionsSelected.map((condition) => jsonEncode(condition.toJson())).toList();
    _prefs.primaryConditions = conditionPrimaryEncoded;

    List<String> conditionSecondaryEncoded = secondaryConditionsSelected.map((condition) => jsonEncode(condition.toJson())).toList();
    _prefs.secondaryConditions = conditionSecondaryEncoded;

    List<String> additionalSecondaryEncoded = additionalConditionsSelected.map((additional) => jsonEncode(additional.toJson())).toList();
    _prefs.additionalConditions = additionalSecondaryEncoded;
    return true;
  }

  _next(BuildContext context) async {
    if (_validateConditions()) {
      Navigator.pushNamed(context, 'onboarding_form');
    }
  }
}
