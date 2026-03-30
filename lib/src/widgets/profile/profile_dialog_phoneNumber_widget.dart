import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/blocs/onboarding_bloc.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/phonenumber_validator.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_widget.dart';

void showPhoneNumberDialog(BuildContext context, String lastPhoneNumber, OnboardingBloc bloc, VoidCallback callback) {
  final _controllerPhoneNumber = new TextEditingController();
  bool editing = lastPhoneNumber.isEmpty ? true : false;
  if (editing) {
    bloc.changePhonenumber("");
  } else {
    _controllerPhoneNumber.text = lastPhoneNumber;
  }

  showProfileDialog(
      context,
      "Phone Number",
      120.0,
      Container(
        height: 120.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Enter your phone number",
                  style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                )),
            SizedBox(height: 10.0),
            Material(
              elevation: 2.5,
              borderRadius: BorderRadius.circular(20.0),
              child: StreamBuilder(
                  stream: bloc.phonenumberStream,
                  builder: (context, snapshot) {
                    return TextFormField(
                      controller: _controllerPhoneNumber,
                      inputFormatters: [PhoneNumberTextInputFormatter()],
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "phone number",
                        hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                        contentPadding: const EdgeInsets.only(left: 25.0, bottom: 10.0, top: 25.0),
                        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                        errorText: snapshot.error as String?,
                        errorStyle: TextStyle(fontSize: 10.0, color: Color.fromRGBO(157, 170, 134, 1.0)),
                        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                        errorBorder: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                      ),
                      onChanged: bloc.changePhonenumber,
                    );
                  }),
            ),
          ],
        ),
      ),
      callback);
}
