import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_marital_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../../../datas/app_data.dart';
import '../../../preferences/user_preference.dart';

void showMaritalDialog(BuildContext context, String lastUsername, VoidCallback callback) {
  final _prefs = new UserPreference();
  List<Marital> maritalList = AppData.dataMaritals;
  final size = MediaQuery.of(context).size;
  Dialog fancyDialog = Dialog(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Container(
      height: 410.0,
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
                "Marital Status",
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
                height: 310.0,
                padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Select your current marital status",
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                        )),
                    SizedBox(height: 10.0),
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: maritalList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final marital = maritalList[index];
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
                                          marital.title!,
                                          style: TextStyle(
                                              color: AppColor.content, fontSize: AppFontSizes.contentSize - 2.5, fontWeight: FontWeight.w700),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (marital.isSelected) {
                                    marital.isSelected = false;
                                    _prefs.maritalStatus = '';
                                  } else {
                                    maritalList.forEach((e) {
                                      e.isSelected = false;
                                    });
                                    marital.isSelected = true;
                                    _prefs.maritalStatus = marital.title!;
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
