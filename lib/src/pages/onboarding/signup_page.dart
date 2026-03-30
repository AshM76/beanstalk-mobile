import 'package:flutter/material.dart';

import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/signin_page.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/routes/transitions/slide_left_transition.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/ageverification_showalert.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/appversion_widget.dart';
import 'package:beanstalk_mobile/src/widgets/logo_widget.dart';

import '../../services/authentication/auth_service.dart';
import '../../services/demo/demo_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final authServices = AuthServices();
  final _prefs = new UserPreference();

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      if (!_prefs.validateAge) {
        ageVerificationShowAlert(context, false);
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: AppColor.background,
      child: Stack(
        children: <Widget>[
          initLogo(context),
          _initSignUpForm(context),
        ],
      ),
    ));
  }

  Widget _initSignUpForm(BuildContext context) {
    final bloc = Provider.signupOf(context);
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SafeArea(
              child: Container(
            height: size.height * 0.35,
          )),
          Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
                  gradient: AppColor.primaryGradient,
                ),
                child: Stack(
                  children: [
                    Column(
                      children: <Widget>[
                        SizedBox(height: size.height * 0.01),
                        _initTitle(),
                        SizedBox(height: size.height * 0.01),
                        _initEmailField(bloc),
                        SizedBox(height: size.height * 0.02),
                        _initFirstNameField(bloc),
                        SizedBox(height: size.height * 0.02),
                        _initLastNameField(bloc),
                        SizedBox(height: size.height * 0.02),
                        _initSignUpButton(bloc),
                        SizedBox(height: size.height * 0.02),
                        _initBottomText(bloc, context),
                        SizedBox(height: size.height * 0.01),
                      ],
                    ),
                  ],
                ),
              ),
              initAppVersion(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _initTitle() {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 70.0,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
      child: Text(
        "Join Us",
        style: TextStyle(
          fontSize: AppFontSizes.titleSize + (size.width * 0.03),
          fontFamily: AppFont.primaryFont,
          color: Colors.white.withOpacity(0.95),
          shadows: <Shadow>[
            Shadow(offset: Offset(0.0, 3.0), blurRadius: 5.0, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _initEmailField(SignUpBloc bloc) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: bloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
          child: Material(
            elevation: 2.5,
            borderRadius: BorderRadius.circular(20.0),
            child: TextField(
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Email",
                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: new BorderRadius.circular(20.0)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                errorText: snapshot.error as String?,
                errorStyle: TextStyle(fontSize: 10.0, color: AppColor.primaryColor),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                errorBorder: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
              ),
              onChanged: bloc.changeEmail,
            ),
          ),
        );
      },
    );
  }

  Widget _initFirstNameField(SignUpBloc bloc) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: bloc.firstnameStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
          child: Material(
            elevation: 2.5,
            borderRadius: BorderRadius.circular(20.0),
            child: TextField(
              enabled: _prefs.demoVersion ? false : true,
              autofocus: false,
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: _prefs.demoVersion ? AppColor.content.withOpacity(0.2) : Colors.white,
                hintText: "First Name",
                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: new BorderRadius.circular(20.0)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                errorText: snapshot.error as String?,
                errorStyle: TextStyle(fontSize: 10.0, color: AppColor.primaryColor),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                errorBorder: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
              ),
              onChanged: bloc.changeFirstname,
            ),
          ),
        );
      },
    );
  }

  Widget _initLastNameField(SignUpBloc bloc) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: bloc.lastnameStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
          child: Material(
            elevation: 2.5,
            borderRadius: BorderRadius.circular(20.0),
            child: TextField(
              enabled: _prefs.demoVersion ? false : true,
              autofocus: false,
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: _prefs.demoVersion ? AppColor.content.withOpacity(0.2) : Colors.white,
                hintText: "Last Name",
                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: new BorderRadius.circular(20.0)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                errorText: snapshot.error as String?,
                errorStyle: TextStyle(fontSize: 10.0, color: AppColor.primaryColor),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                errorBorder: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
              ),
              onChanged: bloc.changeLastname,
            ),
          ),
        );
      },
    );
  }

  Widget _initSignUpButton(SignUpBloc bloc) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: bloc.formValidStream,
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
                            "Request to join",
                            style: TextStyle(
                              fontSize: AppFontSizes.buttonSize + (size.width * 0.0075),
                              color: snapshot.hasData ? Colors.white : Colors.grey[200],
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: EdgeInsets.only(right: size.width * 0.025),
                          child: Icon(
                            Icons.send_rounded,
                            size: 30.0,
                            color: snapshot.hasData ? Colors.white : Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                    onTap: snapshot.hasData ? () => _join(bloc, context) : null,
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _initBottomText(SignUpBloc bloc, BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Center(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.white),
                ),
                TextButton(
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize + 2.0,
                      color: AppColor.fourthColor,
                      fontWeight: FontWeight.bold,
                      shadows: <Shadow>[
                        Shadow(offset: Offset(0.0, 1.5), blurRadius: 5.0, color: Colors.black26),
                      ],
                    ),
                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                  ),
                  onPressed: () {
                    // Navigator.pushNamed(context, 'signin');
                    Navigator.push(context, SlideLeftTransition(transitionTo: SignInPage()));
                    _prefs.logout();
                  },
                )
              ],
            ),
          ],
        )),
        SizedBox(height: size.height * 0.035),
        Text(
          "© ${DateTime.now().year} Beanstalk",
          style: TextStyle(
            fontSize: AppFontSizes.contentSmallSize,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }

  _join(SignUpBloc bloc, BuildContext context) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    if (_prefs.demoVersion) {
      try {
        Map infoResponse = await demoService.sign(bloc.email);
        if (infoResponse['ok']) {
          progressDialog.dismiss();
          _prefs.logout();
          _prefs.email = bloc.email;
          print('email: ${_prefs.email}');
          Navigator.pushNamed(context, 'onboarding_profile');
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
    } else {
      try {
        Map infoResponse = await authServices.signUp(bloc.email, bloc.firstname, bloc.lastname);
        if (infoResponse['ok']) {
          showAlertMessageAction(
              context, "Continue Joining Us", 'Please review your email. Your credentials were sent to continue joining us.', "Done", () {
            progressDialog.dismiss();
            _prefs.logout();
            _prefs.email = bloc.email;
            _prefs.firstname = bloc.firstname;
            _prefs.lastname = bloc.lastname;
            print('email: ${_prefs.email}');
            Navigator.pop(context);
            Navigator.push(context, SlideLeftTransition(transitionTo: SignInPage()));
            _prefs.logout();
          });
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
}
