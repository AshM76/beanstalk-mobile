import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_strainType_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_widget.dart';

void showSpeciesDialog(BuildContext context, VoidCallback callback) {
  final List<StrainType> dataActiveIngredients = AppData.dataStrainTypes;
  final size = MediaQuery.of(context).size;
  showProfileDialog(
      context,
      "Add Species",
      100.0,
      Container(
        height: 120.0,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: dataActiveIngredients.length,
          itemBuilder: (BuildContext context, int index) {
            final activeIngredient = dataActiveIngredients[index];
            return StatefulBuilder(
              builder: (context, setState) {
                return InkWell(
                  child: Container(
                    width: size.width * 0.2,
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                    decoration: BoxDecoration(
                        color: activeIngredient.isSelected ? AppColor().colorSpecies(activeIngredient.title!) : AppColor.content.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Column(
                      children: [
                        Text(
                          activeIngredient.icon!,
                          style: TextStyle(color: Colors.white, fontSize: 50),
                        ),
                        SizedBox(height: 0.5),
                        Container(
                          height: 20.0,
                          width: 70.0,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              activeIngredient.title!,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (activeIngredient.isSelected) {
                        activeIngredient.isSelected = false;
                      } else {
                        activeIngredient.isSelected = true;
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      callback);
}
