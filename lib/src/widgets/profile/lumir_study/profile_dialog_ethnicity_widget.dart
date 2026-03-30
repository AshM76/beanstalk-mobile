import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../../../datas/app_data.dart';
import '../../../models/lumir_study/lumir_ethnicity_model.dart';
import '../../../preferences/user_preference.dart';

void showEthnicityDialog(BuildContext context, String lastUsername, VoidCallback callback) {
  final _prefs = new UserPreference();
  List<Ethnicity> ethnicityList = AppData.dataEthnicites;
  final size = MediaQuery.of(context).size;
  Dialog fancyDialog = Dialog(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Container(
      height: 450.0,
      width: 300.0,
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 60.0,
            alignment: Alignment.bottomCenter,
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
                "Ethnicity",
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
                height: 350.0,
                padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "What would best describe you?",
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                        )),
                    SizedBox(height: 10.0),
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ethnicityList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ethnicity = ethnicityList[index];
                          return StatefulBuilder(builder: (context, setState) {
                            return Card(
                              elevation: 2.5,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.5),
                                side: BorderSide(width: 1.5, color: Colors.transparent),
                              ),
                              child: InkWell(
                                child: SizedBox(
                                  height: size.height * 0.04,
                                  width: size.width * 0.75,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: size.height * 0.005),
                                        Text(
                                          ethnicity.title!,
                                          style: TextStyle(
                                              color: AppColor.content, fontSize: AppFontSizes.contentSize - 2.5, fontWeight: FontWeight.w700),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (ethnicity.isSelected) {
                                    ethnicity.isSelected = false;
                                    _prefs.ethnnicity = '';
                                  } else {
                                    ethnicityList.forEach((e) {
                                      e.isSelected = false;
                                    });
                                    ethnicity.isSelected = true;
                                    _prefs.ethnnicity = ethnicity.title!;
                                  }
                                  callback();
                                },
                              ),
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ),
  );
  showDialog(context: context, builder: (BuildContext context) => fancyDialog);
}
