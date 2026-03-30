import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class ActionCardAddCondition extends StatelessWidget {
  final String text;
  final Size size;
  final VoidCallback callback;

  ActionCardAddCondition(this.text, this.size, this.callback);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      color: AppColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        child: SizedBox(
          height: size.height * 0.07,
          width: size.width * 0.74,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.005),
                Image(
                  height: size.height * 0.035,
                  width: size.width * 0.1,
                  image: AssetImage('assets/img/icon_plusButton.png'),
                  fit: BoxFit.contain,
                  color: AppColor.secondaryColor,
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  '$text',
                  style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSmallSize, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        onTap: callback,
      ),
    );
  }
}
