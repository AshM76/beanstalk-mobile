import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/canna_strainType_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget speciesCardSmall(Size size, StrainType? specie, bool isActive) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(top: size.height * 0.003, bottom: size.height * 0.003),
        child: Text(
          "Species",
          style: TextStyle(
            fontSize: size.width * 0.032,
            color: isActive ? AppColor.fourthColor : AppColor.content,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: 40.0,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              width: size.width * 0.60,
              decoration: BoxDecoration(
                  color: isActive ? AppColor.thirdColor.withOpacity(0.3) : AppColor.content.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(size.width * 0.035)),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: size.width * 0.07,
                    margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              child: Padding(
                            padding: const EdgeInsets.only(right: 7.5),
                            child: Text(
                              specie!.icon!,
                              style:
                                  TextStyle(color: Colors.white, fontSize: size.height * 0.022, fontFamily: "Poppins", fontWeight: FontWeight.w600),
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 5.0,
              child: Image(
                color: AppColor.fifthColor,
                width: 12.0,
                image: AssetImage('assets/img/icon_arrow.png'),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
