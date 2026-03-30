import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_widget.dart';

void showEmailDialog(BuildContext context, String lastEmail,
    OnboardingBloc bloc, VoidCallback callback) {
  final _controllerEmail = new TextEditingController();
  bool editing = lastEmail.isEmpty ? true : false;
  if (editing) {
    bloc.changeEmail("");
  } else {
    _controllerEmail.text = lastEmail;
  }
  showProfileDialog(
      context,
      "Email",
      110.0,
      Container(
        height: 110.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Enter an email",
                  style: TextStyle(
                      fontSize: AppFontSizes.contentSize,
                      color: Colors.grey[600]),
                )),
            SizedBox(height: 10.0),
            Material(
              elevation: 2.5,
              borderRadius: BorderRadius.circular(20.0),
              child: StreamBuilder(
                stream: bloc.emailStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return TextFormField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontSize: AppFontSizes.contentSize,
                        color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "email",
                      hintStyle: TextStyle(
                          fontSize: AppFontSizes.contentSize - 1.0,
                          color: Colors.grey[300]),
                      contentPadding: const EdgeInsets.only(
                          left: 25.0, bottom: 10.0, top: 25.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20.0)),
                      errorText: snapshot.error as String?,
                      errorStyle: TextStyle(
                          fontSize: 10.0,
                          color: Color.fromRGBO(157, 170, 134, 1.0)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20.0)),
                      errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                    onChanged: bloc.changeEmail,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      callback);
}
