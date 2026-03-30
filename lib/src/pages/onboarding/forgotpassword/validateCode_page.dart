import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/blocs/forgotpass_bloc.dart';
import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/authentication/restore_password_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';

class ValidateCodePage extends StatefulWidget {
  @override
  _ValidateCodePageState createState() => _ValidateCodePageState();
}

class _ValidateCodePageState extends State<ValidateCodePage> {
  final restorePasswordServices = RestorePasswordServices();
  final _prefs = new UserPreference();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.forgotpassOf(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.background,
        flexibleSpace: SafeArea(
          child: FlexibleSpaceBar(
            title: Container(
              child: Center(
                child: Image.network(
                  AppLogos.iconImg,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.content,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: AppColor.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.05),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
              child: Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: AppFontSizes.titleSize,
                  fontFamily: AppFont.primaryFont,
                  color: AppColor.primaryColor,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
            ),
            SizedBox(height: size.height * 0.025),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
              child: Text(
                "Please enter the 6 digits code sent to:",
                style: TextStyle(
                  fontSize: AppFontSizes.subTitleSize,
                  color: AppColor.content,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
              child: Text(
                bloc.email,
                style: TextStyle(
                  fontSize: AppFontSizes.subTitleSize,
                  color: AppColor.content,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.025),
            _initCodeField(bloc),
            SizedBox(height: size.height * 0.02),
            _initVerifyCodeButton(bloc),
            Expanded(child: Container()),
            Center(
              child: Text(
                "© ${DateTime.now().year} Lumir Mission",
                style: TextStyle(
                  fontSize: AppFontSizes.contentSmallSize,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _initCodeField(ForgotPassBloc bloc) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: bloc.codeStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
          child: Material(
            elevation: 2.5,
            borderRadius: BorderRadius.circular(20.0),
            child: TextField(
              autofocus: false,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Code",
                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: new BorderRadius.circular(20.0)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                errorText: snapshot.error as String?,
                errorStyle: TextStyle(fontSize: 10.0, color: AppColor.primaryColor),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                errorBorder: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
              ),
              onChanged: bloc.changeCode,
            ),
          ),
        );
      },
    );
  }

  Widget _initVerifyCodeButton(ForgotPassBloc bloc) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: bloc.formCodeValidStream,
        builder: (context, snapshot) {
          return Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: size.width * 0.12),
            child: Material(
              elevation: 2.5,
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                width: size.width * 0.5,
                height: 50.0,
                child: Material(
                  color: snapshot.hasData ? AppColor.secondaryColor : AppColor.content.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20.0),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: size.width * 0.05),
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                              color: snapshot.hasData ? Colors.white : Colors.grey[200],
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: EdgeInsets.only(right: size.width * 0.025),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 30.0,
                            color: snapshot.hasData ? Colors.white : Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                    onTap: snapshot.hasData ? () => _verifyCode(bloc, context) : null,
                  ),
                ),
              ),
            ),
          );
        });
  }

  _verifyCode(ForgotPassBloc bloc, BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse = await restorePasswordServices.passwordCodeValidate(_prefs.email, bloc.code);
      if (infoResponse['ok']) {
        progressDialog.dismiss();
        Navigator.pushNamed(context, 'update_password');
      } else {
        progressDialog.dismiss();
        showAlertMessage(context, infoResponse['message'], () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      progressDialog.dismiss();
      showAlertMessage(context, "A network error occurred", () {
        Navigator.pop(context);
      });
      throw e;
    }
  }
}
