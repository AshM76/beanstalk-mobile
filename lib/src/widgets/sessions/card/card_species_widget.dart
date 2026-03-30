import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/canna_strainType_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget strainCard(Size size, StrainType? strain) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        child: Text(
          "Strain Type",
          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fifthColor, fontWeight: FontWeight.w600),
        ),
      ),
      SizedBox(height: size.height * 0.005),
      Container(
        alignment: Alignment.center,
        height: size.height * 0.1,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.5), borderRadius: BorderRadius.circular(10.0)),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Container(
                        width: size.width * 0.22,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                strain!.title!.toLowerCase() == 'unknown' ? '-' : strain.icon.toString().toUpperCase()[0],
                                style: TextStyle(
                                    color: Colors.white, fontSize: AppFontSizes.titleSize + 15.0, fontFamily: "Poppins", fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          strain.title!,
                          style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSmallSize + 1.5, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: 0.0,
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

Widget speciesCard(Size size, StrainType specie) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        child: Text(
          "Species",
          style: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: 70,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              width: size.width * 0.70,
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(18.0)),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Container(
                        width: size.width * 0.10,
                        margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 7.5),
                        decoration: BoxDecoration(
                          color: AppColor().colorSpecies(specie.title!),
                          borderRadius: BorderRadius.circular(7.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                child: Center(
                              child: Text(
                                specie.icon!,
                                style: TextStyle(color: Colors.white, fontSize: 35.0, fontFamily: "Poppins", fontWeight: FontWeight.w700),
                              ),
                            )),
                          ],
                        ),
                      ),
                      SizedBox(width: size.width * 0.025),
                      Center(
                        child: Text(
                          specie.title!,
                          style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize + 1.0, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: 5.0,
              child: Image(
                color: AppColor.fifthColor,
                width: 17.5,
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
