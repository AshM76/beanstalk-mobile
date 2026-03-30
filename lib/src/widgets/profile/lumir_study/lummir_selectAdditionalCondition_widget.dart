import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_additional_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../../../datas/app_data.dart';

void showSelectAdditionalConditionDialog(
    BuildContext context, List<Additional> additionalConditions, Function(void Function()) setState, Function(List<Additional>) callback) {
  List<Additional> _dataConditions = [];
  _dataConditions.addAll(AppData.dataAdditionals);
  List<Additional> _additionalConditions = [];
  _dataConditions.forEach((condition) {
    condition.isSelected = false;
  });
  additionalConditions.forEach((additionalCondition) {
    _dataConditions.forEach((condition) {
      condition.isSelected = false;
      if (additionalCondition.title == condition.title) {
        condition.isSelected = true;
        _additionalConditions.add(condition);
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
                  height: size.height * 0.6,
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
                                  callback(_additionalConditions);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: size.height * 0.08,
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "In addition to the above conditions, do you have any of the following?",
                          style: TextStyle(
                            color: AppColor.content,
                            fontSize: AppFontSizes.subTitleSize,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: size.width * 0.05),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _dataConditions.length,
                          itemBuilder: (BuildContext context, int index) {
                            final additional = _dataConditions[index];
                            return StatefulBuilder(builder: (context, setState) {
                              return InkWell(
                                child: Container(
                                  height: size.height * 0.05,
                                  width: size.width * 0.75,
                                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.5),
                                  decoration: additional.isSelected
                                      ? BoxDecoration(
                                          gradient: AppColor.secondaryGradient,
                                          borderRadius: BorderRadius.circular(size.width * 0.025),
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
                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                        ),
                                  child: Center(
                                    child: Text(
                                      additional.title!,
                                      style: TextStyle(
                                          color: additional.isSelected ? AppColor.background : AppColor.thirdColor,
                                          fontSize: AppFontSizes.contentSize - 2.5,
                                          fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    if (additional.isSelected) {
                                      additional.isSelected = false;
                                      _additionalConditions.removeWhere((tempCondition) => tempCondition.title == additional.title);
                                    } else {
                                      additional.isSelected = true;
                                      _additionalConditions.add(additional);
                                    }
                                  });
                                },
                              );
                            });
                          },
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
