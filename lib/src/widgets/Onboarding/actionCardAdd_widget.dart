import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class ActionCardAdd extends StatelessWidget {
  final String text;
  final String image;
  final Size size;
  final VoidCallback callback;

  ActionCardAdd(this.text, this.image, this.size, this.callback);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        child: SizedBox(
          height: size.height * 0.075,
          width: size.width * 0.125,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.005),
                Image(
                  height: size.height * 0.035,
                  width: size.width * 0.1,
                  image: AssetImage('assets/img/$image'),
                  fit: BoxFit.contain,
                  color: AppColor.thirdColor,
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
