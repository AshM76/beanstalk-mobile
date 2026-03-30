import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_medication_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class ActionCardMedication extends StatelessWidget {
  final Medication medication;
  final VoidCallback callback;

  ActionCardMedication(this.medication, this.callback);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(width: 2.0, color: medication.isSelected ? AppColor.secondaryColor : Colors.transparent),
      ),
      child: InkWell(
        child: SizedBox(
          width: 100.0,
          height: 120.0,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0),
                    Image(
                      height: 70.0,
                      width: 70.0,
                      image: AssetImage('assets/img/medication/${AppData().iconMedication(medication.title!)}'),
                      fit: BoxFit.contain,
                      color: medication.isSelected ? AppColor.secondaryColor : AppColor.primaryColor,
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '${medication.title}',
                      style: TextStyle(
                        color: AppColor.content,
                        fontSize: AppFontSizes.contentSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: callback,
      ),
    );
  }
}
