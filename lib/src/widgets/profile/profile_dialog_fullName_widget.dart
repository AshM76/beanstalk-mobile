import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_widget.dart';

void showFullNameDialog(BuildContext context, String lastFirstname, String lastLastname, VoidCallback callback) {
  final _prefs = new UserPreference();
  final _controllerFirstName = new TextEditingController();
  final _controllerlastName = new TextEditingController();
  bool editing = lastFirstname.isEmpty ? true : false;
  if (editing) {
    _prefs.firstname = "";
    _prefs.lastname = "";
  } else {
    _controllerFirstName.text = lastFirstname;
    _controllerlastName.text = lastLastname;
  }

  showProfileDialog(
      context,
      "Your Name",
      200.0,
      Container(
        height: 200.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Enter your name",
                  style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                )),
            SizedBox(height: 10.0),
            Material(
              elevation: 2.5,
              borderRadius: BorderRadius.circular(20.0),
              child: TextField(
                controller: _controllerFirstName,
                autofocus: true,
                style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "First name",
                    hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                    errorText: null, //"\u26A0 email incorrecto",
                    contentPadding: const EdgeInsets.only(left: 25.0, bottom: 10.0, top: 25.0),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    border:
                        OutlineInputBorder(borderRadius: new BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                    errorStyle: TextStyle(fontSize: 11.0)),
                onChanged: (value) {
                  _prefs.firstname = value;
                },
              ),
            ),
            SizedBox(height: 10.0),
            Material(
              elevation: 2.5,
              borderRadius: BorderRadius.circular(20.0),
              child: TextField(
                controller: _controllerlastName,
                autofocus: true,
                style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Last name",
                    hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                    errorText: null, //"\u26A0 email incorrecto",
                    contentPadding: const EdgeInsets.only(left: 25.0, bottom: 10.0, top: 25.0),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    border:
                        OutlineInputBorder(borderRadius: new BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                    errorStyle: TextStyle(fontSize: 11.0)),
                onChanged: (value) {
                  _prefs.lastname = value;
                },
              ),
            ),
            SizedBox(height: 10.0),
            Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'We will not share publicly',
                  style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: Colors.grey[600]),
                )),
          ],
        ),
      ),
      callback);
}
