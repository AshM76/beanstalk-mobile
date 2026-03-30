import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_activeIngredients_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_method_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_species_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_conditions_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_terpenes_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_value_heightCard_widget.dart';

void showCardSession(BuildContext context, Session? currentSession) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 300),
    context: context,
    pageBuilder: (_, __, ___) {
      return sessionInfo(context, currentSession!);
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

Widget sessionInfo(BuildContext context, Session currentSession) {
  final size = MediaQuery.of(context).size;
  return Dialog(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(size.width * 0.1),
    ),
    child: Stack(
      children: [
        Container(
          height: valueHeightCard(size, currentSession) + 30.0,
          width: size.width * 0.9,
          decoration: BoxDecoration(gradient: AppColor.primaryGradient, borderRadius: BorderRadius.circular(size.width * 0.1)),
          child: Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.022,
              left: size.width * 0.03,
              right: size.width * 0.02,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Session Info.",
                        style: TextStyle(
                          fontSize: AppFontSizes.subTitleSize,
                          color: AppColor.fifthColor,
                          fontFamily: AppFont.primaryFont,
                        ),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                      Divider(
                        height: size.width * 0.05,
                        thickness: 2,
                        color: AppColor.fifthColor.withOpacity(0.75),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      primaryConditionsCard(size, currentSession.primaryCondition!),
                      SizedBox(
                        height: size.height * 0.12,
                        child: VerticalDivider(
                          width: size.width * 0.05,
                          thickness: 2,
                          color: AppColor.thirdColor.withOpacity(0.5),
                          indent: size.height * 0.025,
                        ),
                      ),
                      infoConditionsCard(size, currentSession.secondaryCondition!),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      productTypeCard(size, currentSession.productType!),
                      SizedBox(
                        height: size.height * 0.12,
                        child: VerticalDivider(
                          width: size.width * 0.05,
                          thickness: 2,
                          color: AppColor.thirdColor.withOpacity(0.6),
                          indent: size.height * 0.025,
                        ),
                      ),
                      infoProductTypeCard(size, currentSession.deliveryMethodType!.title, currentSession.strainType!.title!),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      strainCard(size, currentSession.strainType),
                      SizedBox(
                        height: size.height * 0.12,
                        child: VerticalDivider(
                          width: size.width * 0.05,
                          thickness: 2,
                          color: AppColor.thirdColor.withOpacity(0.8),
                          indent: size.height * 0.025,
                        ),
                      ),
                      infoProductCard(size, currentSession.productBrand!, currentSession.productName!, currentSession.temperature!,
                          currentSession.temperatureMeasurement!.title), //36-°C
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  currentSession.cannabinoids!.length > 0
                      ? activeIngredientsCard(size, currentSession.cannabinoids!, currentSession.activeIngredientsMeasurement!.title, false)
                      : Container(),
                  currentSession.terpenes!.length > 0
                      ? terpenesCard(size, currentSession.terpenes!, currentSession.activeIngredientsMeasurement!.title, false)
                      : Container(),
                  // currentSession.sessionNote.length > 0 ? noteCard(size, currentSession.sessionNote) : Container(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          child: InkWell(
            child: Container(
              height: 35.0,
              width: 35.0,
              decoration: BoxDecoration(
                color: AppColor.background,
                borderRadius: BorderRadius.circular(17.5),
              ),
              child: Icon(
                Icons.close,
                color: AppColor.thirdColor,
                size: 25.0,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        )
      ],
    ),
  );
}
