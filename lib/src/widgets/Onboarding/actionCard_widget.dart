import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class ActionCard extends StatelessWidget {
  final String text;
  final String image;
  final Size size;
  final bool selected;
  final VoidCallback callback;

  ActionCard(this.text, this.image, this.size, this.selected, this.callback);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      color: selected ? AppColor.secondaryColor : AppColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(width: 1.5, color: selected ? AppColor.background : Colors.transparent),
      ),
      child: InkWell(
        child: SizedBox(
          height: size.height * 0.05,
          width: size.width * 0.35,
          child: Align(
            alignment: Alignment.center,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15.0),
                  width: size.width * 0.1,
                  child: Image(
                    height: size.height * 0.035,
                    image: AssetImage('assets/img/$image'),
                    fit: BoxFit.contain,
                    color: selected ? AppColor.background : AppColor.primaryColor,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$text',
                      maxLines: 2,
                      style: TextStyle(
                          color: selected ? AppColor.background : AppColor.primaryColor,
                          fontSize: AppFontSizes.contentSmallSize + 1.0,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
