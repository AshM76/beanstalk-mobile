import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../preferences/user_preference.dart';

Widget initLogo(BuildContext context) {
  final _prefs = new UserPreference();
  final size = MediaQuery.of(context).size;
  return Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(top: size.height * 0.12),
    child: Column(
      children: [
        Container(
          child: Image.network(
            AppLogos.logoImg,
            width: size.width * 0.55,
            height: size.height * 0.25,
            fit: BoxFit.contain,
          ),
        ),
        _prefs.demoVersion
            ? Container(
                child: Image.network(
                  "https://storage.googleapis.com/beanstalk-assets/logos/logo_skinning.png",
                  width: size.width * 0.4,
                  height: size.height * 0.055,
                  fit: BoxFit.contain,
                ),
              )
            : Container(),
      ],
    ),
  );
}
