import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class ActionCardOption extends StatelessWidget {
  final String text;
  final Size size;
  final bool selected;
  final VoidCallback callback;

  ActionCardOption(this.text, this.size, this.selected, this.callback);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      color: selected ? AppColor.secondaryColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.5),
        side: BorderSide(
            width: 1.5,
            color: selected ? AppColor.background : Colors.transparent),
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
                  '$text',
                  style: TextStyle(
                      color: selected ? AppColor.background : AppColor.content,
                      fontSize: AppFontSizes.contentSize - 2.5,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w700),
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
