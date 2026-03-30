import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../../../datas/app_data.dart';
import '../../../models/canna_condition_model.dart';

void showSelectConditionDialog(
    BuildContext context, List<Condition> sessionConditions, Function(void Function()) setState, Function(List<Condition>) callback) {
  List<Condition> _dataConditions = [];
  _dataConditions.addAll(AppData.dataConditions);
  List<Condition> _primaryConditions = [];
  sessionConditions.forEach((primaryCondition) {
    _dataConditions.forEach((condition) {
      condition.isSelected = false;
      if (primaryCondition.title == condition.title) {
        condition.isSelected = true;
        _primaryConditions.add(condition);
      }
    });
  });
  final size = MediaQuery.of(context).size;
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
                                  callback(_primaryConditions);
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
                          "Please Select Your Primary Condition",
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
                                        color: AppColor.background,
                                        border: Border.all(color: AppColor.thirdColor),
                                        borderRadius: BorderRadius.circular(size.width * 0.05),
                                      ),
                                child: ClipRRect(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        color: condition.isSelected ? AppColor.background : AppColor.thirdColor,
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
                                                color: condition.isSelected ? AppColor.background : AppColor.thirdColor,
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
                                setState(() {
                                  _primaryConditions = [];
                                  _dataConditions.forEach((conditionsTemp) {
                                    conditionsTemp.isSelected = false;
                                  });
                                  if (condition.isSelected) {
                                    condition.isSelected = false;
                                  } else {
                                    condition.isSelected = true;
                                    _primaryConditions.add(condition);
                                  }
                                });
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

// double _conditionTextSize(int length) {
//   switch (length) {
//     case length > 10:
//       return AppFontSizes.contentSize;
//       break;
//     case 15:
//       return AppFontSizes.contentSize;
//       break;
//     case 15:
//       return AppFontSizes.contentSize;
//       break;
//     default:
//   }
// }
