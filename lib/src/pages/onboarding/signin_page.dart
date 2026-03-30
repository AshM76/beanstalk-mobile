import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/datas/app_secure_storage.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/authentication/auth_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/ageverification_showalert.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/appversion_widget.dart';
import 'package:beanstalk_mobile/src/widgets/logo_widget.dart';

import '../../services/demo/demo_service.dart';

// Onesignal
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final authServices = AuthServices();
  final _prefs = new UserPreference();
  bool remember = false;

  bool passenable = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool savedCredentials = false;

  String secureDataEmail = '';
  String secureDataPassword = '';

  @override
  void initState() {
    super.initState();

    () async {
      await Future.delayed(Duration.zero);
      if (!_prefs.validateAge) {
        ageVerificationShowAlert(context, false);
      }
      initLoadSecureData();
    }();
  }

  Future initLoadSecureData() async {
    //SecureDataSave
    secureDataEmail = await SecureStorage().getSecureEmail() ?? '';
    secureDataPassword = await SecureStorage().getSecurePassword() ?? '';
    setState(() {
      if (secureDataEmail.isNotEmpty) {
        remember = true;
        emailController.text = secureDataEmail;
      }
      if (secureDataEmail.isNotEmpty && secureDataPassword.isNotEmpty) {
        savedCredentials = true;
        emailController.text = secureDataEmail;
        passwordController.text = secureDataPassword;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: AppColor.background,
      child: Stack(
        children: <Widget>[
          initLogo(context),
          _initSignInForm(context),
        ],
      ),
    ));
  }

  Widget _initSignInForm(BuildContext context) {
    final bloc = Provider.siginOf(context);

    if (secureDataEmail.isNotEmpty) {
      bloc.changeEmail(emailController.text);
    }
    if (secureDataEmail.isNotEmpty && secureDataPassword.isNotEmpty) {
      bloc.changeEmail(emailController.text);
      bloc.changePassword(passwordController.text);
    }

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
                    gradient: AppColor.primaryGradient),
                child: Stack(
                  children: [
                    Column(
                      children: <Widget>[
                        SizedBox(height: size.height * 0.01),
                        _initTitle(),
                        SizedBox(height: size.height * 0.01),
                        AutofillGroup(
                          onDisposeAction: AutofillContextAction.commit,
                          child: Column(
                            children: [
                              // TextField(
                              //   controller: emailController,

                              //   decoration: InputDecoration(
                              //     hintText: 'Email',
                              //   ),
                              // ),
                              // TextField(
                              //   controller: passwordController,
                              //   autofillHints: const [
                              //     AutofillHints.password,
                              //   ],
                              //   decoration: InputDecoration(
                              //     hintText: 'Password',
                              //   ),
                              //   onEditingComplete: () => TextInput.finishAutofillContext(),
                              // ),
                              // ElevatedButton(
                              //   child: Text('Save account info'),
                              //   onPressed: () {
                              // TextInput.finishAutofillContext(shouldSave: true);
                              // TextInput.finishAutofillContext();
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                              //   return SignUpPage();
                              // }));
                              //   },
                              // ),
                              _initEmailField(bloc),
                              SizedBox(height: size.height * 0.02),
                              _initPasswordField(bloc),
                              SizedBox(height: size.height * 0.02),
                              _initButtonfield(bloc),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        _initBottomText(context),
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
        "Welcome back",
        style: TextStyle(
          fontSize: AppFontSizes.titleSize + (size.width * 0.03),
          fontFamily: AppFont.primaryFont,
          color: Colors.white,
          shadows: <Shadow>[
            Shadow(offset: Offset(0.0, 3.0), blurRadius: 5.0, color: Colors.grey),
          ],
        ),
        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
      ),
    );
  }

  Widget _initEmailField(SignInBloc bloc) {
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
              controller: emailController,
              autofillHints: const [
                AutofillHints.email,
              ],
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Email",
                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
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

  Widget _initPasswordField(SignInBloc bloc) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        StreamBuilder(
          stream: bloc.passwordStream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
              child: Material(
                elevation: 2.5,
                borderRadius: BorderRadius.circular(20.0),
                child: TextField(
                  controller: passwordController,
                  autofillHints: const [
                    AutofillHints.password,
                  ],
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                  enabled: _prefs.demoVersion ? false : true,
                  autofocus: false,
                  obscureText: passenable,
                  style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black87),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _prefs.demoVersion ? AppColor.content.withOpacity(0.2) : Colors.white,
                    hintText: "Password",
                    hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                    contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                    errorText: snapshot.error as String?,
                    errorStyle: TextStyle(fontSize: 10.0, color: AppColor.primaryColor),
                    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                    errorBorder: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                    suffixIcon: IconButton(
                        iconSize: 20.0,
                        onPressed: () {
                          setState(() {
                            if (passenable) {
                              passenable = false;
                            } else {
                              passenable = true;
                            }
                          });
                        },
                        icon: Icon(
                          passenable == true ? Icons.remove_red_eye : Icons.password,
                          color: AppColor.content,
                        )),
                  ),
                  onChanged: bloc.changePassword,
                ),
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: AppFontSizes.contentSize,
                  color: AppColor.background,
                  height: 2.0,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(offset: Offset(0.0, 1.0), blurRadius: 2.5, color: Colors.black26),
                  ],
                ),
              ),
              onTap: () {
                if (_prefs.demoVersion) {
                  showAlertMessage(context, 'Not available in demo version', () {
                    Navigator.pop(context);
                  });
                } else {
                  Navigator.pushNamed(context, 'forgot_password');
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _initButtonfield(SignInBloc bloc) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
      child: Row(
        children: [
          _initRememberField(),
          Expanded(child: SizedBox()),
          _initLogInButton(bloc),
        ],
      ),
    );
  }

  Widget _initRememberField() {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(left: size.width * 0.032),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Remember me",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.contentSize - 1.0,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(width: size.width * 0.01),
          InkWell(
            child: Icon(
              remember ? Icons.check_box_rounded : Icons.crop_square_rounded,
              size: 22.5,
              color: remember ? AppColor.fourthColor : AppColor.background.withOpacity(0.8),
            ),
            onTap: () {
              setState(() {
                if (remember) {
                  remember = false;
                } else {
                  remember = true;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _initLogInButton(SignInBloc bloc) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: bloc.formValidStream,
        builder: (context, snapshot) {
          return Container(
            child: Material(
              elevation: 2.5,
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                width: size.width * 0.35,
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
                              "Log in",
                              style: TextStyle(
                                fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                                color: snapshot.hasData ? Colors.white : Colors.grey[200],
                                fontWeight: FontWeight.bold,
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
                      onTap: snapshot.hasData
                          ? () {
                              TextInput.finishAutofillContext(shouldSave: true);
                              _login(bloc, context);
                            }
                          : null),
                ),
              ),
            ),
          );
        });
  }

  Widget _initBottomText(BuildContext context) {
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
                  "Don't have an account?",
                  style: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.white),
                ),
                TextButton(
                  child: Text(
                    'Join Us',
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
                    Navigator.pushNamed(context, 'signup');
                  },
                )
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Column(
              children: [
                Text(
                  "By continuing you're agreeing to our",
                  style: TextStyle(
                    fontSize: AppFontSizes.contentSmallSize,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    "privacy policy and terms of service",
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSmallSize,
                      color: AppColor.fourthColor,
                      height: 1.5,
                    ),
                  ),
                  onTap: () {
                    showAlertMessageAction(context, "Policy and Terms", 'Privacy policy and term of service', "Done", () {
                      _prefs.validateAge = false;
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ],
        )),
        SizedBox(height: size.height * 0.03),
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

  _login(SignInBloc bloc, BuildContext context) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse;
      _prefs.demoVersion ? infoResponse = await demoService.sign(bloc.email) : infoResponse = await authServices.signIn(bloc.email, bloc.password);
      if (infoResponse['ok']) {
        if (remember) {
          //SecureDataSave
          await SecureStorage().setSecureEmail(bloc.email);
        }
        _prefs.email = bloc.email;
        _prefs.password = bloc.password;

        if (savedCredentials) {
          //OneSinal
          OneSignal.login(_prefs.id);
          //
          progressDialog.dismiss();
          if (_prefs.onboard) {
            Navigator.pushReplacementNamed(context, 'navigation');
          } else {
            //onboarding_information
            Navigator.pushNamed(context, 'onboarding_agree');
          }
        } else {
          _confirmSaveCredentials(context, () async {
            print('Save Credentials');
            //SecureDataSave
            await SecureStorage().setSecureEmail(bloc.email);
            await SecureStorage().setSecurePassword(bloc.password);
            //OneSinal
            OneSignal.login(_prefs.id);
            //
            progressDialog.dismiss();
            if (_prefs.onboard) {
              Navigator.pushReplacementNamed(context, 'navigation');
            } else {
              //onboarding_information
              Navigator.pushNamed(context, 'onboarding_agree');
            }
          }, () {
            print('Not Saved');
            // SecureStorage().deleteSecureData('login_email');
            // SecureStorage().deleteSecureData('login_password');
            //OneSinal
            OneSignal.login(_prefs.id);
            //
            progressDialog.dismiss();
            if (_prefs.onboard) {
              Navigator.pushReplacementNamed(context, 'navigation');
            } else {
              //onboarding_information
              Navigator.pushNamed(context, 'onboarding_agree');
            }
          });
        }
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

  _confirmSaveCredentials(BuildContext context, Function() saveCredentials, Function() notSaveCredentials) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: AppColor.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return Container(
            height: 270.0,
            child: Card(
              color: AppColor.background,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
              ),
              child: Container(
                  child: Column(
                children: [
                  SizedBox(height: 10.0),
                  Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      color: AppColor.content.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(size.width * 0.025),
                    ),
                    child: Icon(
                      Icons.key_rounded,
                      size: 35.0,
                      color: AppColor.background,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Would you like to save this credentials",
                    style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize + 2.0, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColor.content.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(size.width * 0.025),
                          ),
                          child: TextButton(
                            child: Text(
                              "Save Credential",
                              style: TextStyle(color: AppColor.secondaryColor, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              saveCredentials();
                            },
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColor.content.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(size.width * 0.025),
                          ),
                          child: TextButton(
                              child: Text(
                                "Not Now",
                                style: TextStyle(
                                  color: AppColor.background,
                                  fontSize: AppFontSizes.buttonSize + 5.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () {
                                notSaveCredentials();
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
          );
        });
  }
}
