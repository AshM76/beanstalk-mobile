import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../../../datas/app_data.dart';
import '../../../models/canna_condition_model.dart';
import '../../../utils/utils.dart';

void showSelectSecondaryConditionDialog(BuildContext context, List<Condition> sessionPrimaryConditions, List<Condition> sessionSecondaryConditions,
    Function(void Function()) setState, Function(List<Condition>) callback) {
  final size = MediaQuery.of(context).size;

  int _maxConditionSelected = 3;
  int _currentConditionsSelected = 0;

  List<Condition> _dataConditions = [];
  _dataConditions.addAll(AppData.dataConditions);
  List<Condition> _secondaryConditions = [];
  _dataConditions.forEach((condition) {
    condition.isSelected = false;
  });
  sessionSecondaryConditions.forEach((secondaryCondition) {
    _dataConditions.forEach((condition) {
      if (secondaryCondition.title == condition.title) {
        condition.isSelected = true;
        _secondaryConditions.add(condition);
      }
    });
  });
  var _primaryCondition = sessionPrimaryConditions.length > 0 ? sessionPrimaryConditions[0].title : '';
  _currentConditionsSelected = _secondaryConditions.length.toInt();
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (context) {
        return BottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Container(
                  height: size.height * 0.75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: size.height * 0.075,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                          gradient: AppColor.secondaryGradient,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              TextButton(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppFontSizes.buttonSize + 5.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              Expanded(child: SizedBox()),
                              TextButton(
                                child: Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w800),
                                ),
                                onPressed: () {
                                  callback(_secondaryConditions);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: size.height * 0.05,
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Please Select Your Secondary Condition",
                          style: TextStyle(
                            color: AppColor.content,
                            fontSize: AppFontSizes.subTitleSize,
                          ),
                        ),
                      ),
                      Container(
                        height: size.height * 0.55,
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child: GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 0.5,
                          crossAxisSpacing: 0.5,
                          childAspectRatio: 0.8,
                          children: List.generate(_dataConditions.length, (index) {
                            final condition = _dataConditions[index];
                            return InkWell(
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                                decoration: condition.isSelected
                                    ? BoxDecoration(
                                        gradient: AppColor.secondaryGradient,
                                        borderRadius: BorderRadius.circular(size.width * 0.05),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.7),
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 2.5,
                                          ),
                                        ],
                                      )
                                    : BoxDecoration(
                                        color: condition.title == _primaryCondition ? AppColor.content.withOpacity(0.1) : AppColor.background,
                                        border: Border.all(
                                            color: condition.title == _primaryCondition ? AppColor.content.withOpacity(0.5) : AppColor.thirdColor),
                                        borderRadius: BorderRadius.circular(size.width * 0.05),
                                      ),
                                child: ClipRRect(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        color: condition.isSelected
                                            ? AppColor.background
                                            : condition.title == _primaryCondition
                                                ? AppColor.content.withOpacity(0.5)
                                                : AppColor.thirdColor,
                                        height: size.height * 0.075,
                                        image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(height: size.height * 0.0075),
                                      Container(
                                        height: size.height * 0.037,
                                        child: Center(
                                          child: Text(
                                            condition.title!,
                                            style: TextStyle(
                                                color: condition.isSelected
                                                    ? AppColor.background
                                                    : condition.title == _primaryCondition
                                                        ? AppColor.content.withOpacity(0.5)
                                                        : AppColor.thirdColor,
                                                fontSize: condition.title!.length < 25
                                                    ? AppFontSizes.contentSize - 1.0
                                                    : AppFontSizes.contentSmallSize - 2.0,
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
                              onTap: () {
                                if (condition.title != _primaryCondition) {
                                  setState(() {
                                    if (condition.isSelected) {
                                      condition.isSelected = false;
                                      _currentConditionsSelected -= 1;
                                      _secondaryConditions.removeWhere((tempCondition) => tempCondition.title == condition.title);
                                    } else {
                                      if (_currentConditionsSelected < _maxConditionSelected && !(condition.isSelected)) {
                                        condition.isSelected = true;
                                        _currentConditionsSelected += 1;
                                        _secondaryConditions.add(condition);
                                      } else {
                                        showAlertMessage(context, "You can select up to three (3) secondary conditions", () {
                                          Navigator.pop(context);
                                        });
                                      }
                                    }
                                  });
                                  // setState(() {
                                  //   if (condition.isSelected) {
                                  //     condition.isSelected = false;
                                  //     _currentSymptomsSelected -= 1;
                                  //     _currentSession.condition.removeWhere((s) => s.title == condition.title);
                                  //   } else {
                                  //     if (_currentSymptomsSelected < _maxSymptomsSelected && !(sympthom.isSelected)) {
                                  //       sympthom.isSelected = true;
                                  //       _currentSymptomsSelected += 1;
                                  //       _currentSession.symptoms.add(sympthom);
                                  //     } else {
                                  //       showAlertMessage(context, "You can select up to four symptoms", () {
                                  //         Navigator.pop(context);
                                  //       });
                                  //     }
                                  //   }
                                  //   List<String> listSymtoms = [];
                                  //   _currentSession.symptoms.forEach((s) {
                                  //     listSymtoms.add(s.title);
                                  //   });
                                  //   print("> Symptoms: $listSymtoms");
                                  // });
                                }
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          onClosing: () {},
        );
      });
}
