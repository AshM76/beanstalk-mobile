import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_education_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_employment_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_ethnicity_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_marital_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/user/user_profile_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/actionCardAdd_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/nextButton_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/fieldContent_widget.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backgroundPaint_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/actionCard_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/titleForm_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/backButton_widget.dart';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class OnboardingProfilePage extends StatefulWidget {
  @override
  _OnboardingProfilePageState createState() => _OnboardingProfilePageState();
}

class _OnboardingProfilePageState extends State<OnboardingProfilePage> {
  final _prefs = new UserPreference();
  final userProfileServices = UserProfileServices();

  // ignore: unused_field
  String _authStatus = 'Unknown';

  bool _selectedUserInfo = true;

  bool _selectedUserName = false;

  bool _selectedGenderMale = false;
  bool _selectedGenderFemale = false;
  bool _selectedGenderFluid = false;
  bool _selectedGenderSelf = false;

  bool _selectedAge = false;

  bool _switchedNotifications = true;

  DateTime currentDate = DateTime.now();

  List<Ethnicity> ethnicityList = AppData.dataEthnicites;
  bool _selectedEthnicity = false;

  List<Marital> maritalList = AppData.dataMaritals;
  bool _selectedMaritalStatus = false;

  List<Employment> employmentList = AppData.dataEmployments;
  bool _selectedEmploymentStatus = false;

  List<Education> educationList = AppData.dataEducations;
  bool _selectedEducation = false;

  @override
  void initState() {
    super.initState();
    clearProfile();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => initPlugin());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Request system's tracking authorization dialog
      final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: AppColor.background,
      child: Stack(
        children: <Widget>[
          initBackgroundPaint(context),
          _initProfileForm(context),
          backButton(context),
        ],
      ),
    ));
  }

  Widget _initProfileForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              initTitle("About You"),
              _initHeader(context),
              SizedBox(height: size.height * 0.01),
              _initInformation(context),
              SizedBox(height: size.height * 0.01),
              _initUserName(context),
              SizedBox(height: size.height * 0.01),
              _initGender(context),
              SizedBox(height: size.height * 0.01),
              _initAge(context),
              SizedBox(height: size.height * 0.01),
              _initEthnicity(context),
              SizedBox(height: size.height * 0.01),
              _initMarital(context),
              SizedBox(height: size.height * 0.01),
              _initEmployment(context),
              SizedBox(height: size.height * 0.01),
              _initEducation(context),
              SizedBox(height: size.height * 0.01),
              _initAllowActions(),
              SizedBox(height: size.height * 0.02),
              initNextButton(context, () {
                _next(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initHeader(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Patient Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.subTitleSize,
                ),
                textAlign: TextAlign.left,
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
              Text(
                " *",
                style: TextStyle(
                  fontSize: AppFontSizes.contentSize,
                  fontFamily: AppFont.primaryFont,
                  color: AppColor.fourthColor,
                  fontWeight: FontWeight.w700,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              )
            ],
          ),
          Container(
            width: 250.0,
            height: 45.0,
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColor.thirdColor.withOpacity(0.3), border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10.0)),
            child: Text(
              _prefs.email,
              style: TextStyle(fontSize: AppFontSizes.contentSize + 1.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initInformation(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Patient Name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.subTitleSize,
                ),
                textAlign: TextAlign.left,
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
              Text(
                " *",
                style: TextStyle(
                  fontSize: AppFontSizes.contentSize,
                  fontFamily: AppFont.primaryFont,
                  color: AppColor.fourthColor,
                  fontWeight: FontWeight.w700,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              )
            ],
          ),
          _showInformationContent(context),
        ],
      ),
    );
  }

  Widget _showInformationContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!_selectedUserInfo) {
      return Row(
        children: [
          ActionCardAdd("add", "icon_plusButton.png", size, () {
            setState(() {
              _showUserInformationDialog(context, () {
                bool firstname = _prefs.firstname.isEmpty ? false : true;
                bool lastname = _prefs.lastname.isEmpty ? false : true;

                if (firstname || lastname) {
                  setState(() {
                    _selectedUserInfo = true;
                    Navigator.of(context).pop();
                  });
                }
              });
            });
          }),
        ],
      );
    } else {
      return showFieldContent("${_prefs.firstname} ${_prefs.lastname}", 250.0, () {
        setState(() {
          _prefs.firstname = '';
          _prefs.lastname = '';
          _selectedUserInfo = false;
        });
      });
    }
  }

  Widget _initUserName(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Username",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _showUserNameContent(context),
        ],
      ),
    );
  }

  Widget _showUserNameContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!_selectedUserName) {
      return Row(
        children: [
          ActionCardAdd("add", "icon_plusButton.png", size, () {
            setState(() {
              _showUserNameDialog(context, () {
                bool username = _prefs.username.isEmpty ? false : true;
                if (username) {
                  setState(() {
                    _selectedUserName = true;
                    Navigator.of(context).pop();
                  });
                }
              });
            });
          }),
        ],
      );
    } else {
      return showFieldContent(_prefs.username, 250.0, () {
        setState(() {
          _prefs.username = '';
          _selectedUserName = false;
        });
      });
    }
  }

  Widget _initGender(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          Row(
            children: [
              Column(
                children: [
                  ActionCard("Male", "icon_male.png", size, _selectedGenderMale, () {
                    setState(() {
                      if (_selectedGenderMale == true) {
                        _selectedGenderMale = false;
                        _prefs.gender = "";
                      } else {
                        _selectedGenderMale = true;
                        _selectedGenderFemale = false;
                        _selectedGenderFluid = false;
                        _selectedGenderSelf = false;
                        _prefs.gender = "male";
                      }
                    });
                  }),
                  ActionCard("Female", "icon_female.png", size, _selectedGenderFemale, () {
                    setState(() {
                      if (_selectedGenderFemale == true) {
                        _selectedGenderFemale = false;
                        _prefs.gender = "";
                      } else {
                        _selectedGenderMale = false;
                        _selectedGenderFemale = true;
                        _selectedGenderFluid = false;
                        _selectedGenderSelf = false;
                        _prefs.gender = "female";
                      }
                    });
                  }),
                ],
              ),
              Column(
                children: [
                  ActionCard("Gender Fluid", "icon_fluid.png", size, _selectedGenderFluid, () {
                    setState(() {
                      if (_selectedGenderFluid == true) {
                        _selectedGenderFluid = false;
                        _prefs.gender = "";
                      } else {
                        _selectedGenderMale = false;
                        _selectedGenderFemale = false;
                        _selectedGenderFluid = true;
                        _selectedGenderSelf = false;
                        _prefs.gender = "fluid";
                      }
                    });
                  }),
                  ActionCard("Self-Description", "icon_self.png", size, _selectedGenderSelf, () {
                    setState(() {
                      if (_selectedGenderSelf == true) {
                        _selectedGenderSelf = false;
                        _prefs.gender = "";
                      } else {
                        _showGenderSelfDescriptionDialog(context, () {
                          bool genderSelf = _prefs.gender.isEmpty ? false : true;
                          if (genderSelf) {
                            setState(() {
                              _selectedGenderMale = false;
                              _selectedGenderFemale = false;
                              _selectedGenderFluid = false;
                              _selectedGenderSelf = true;
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      }
                    });
                  }),
                ],
              ),
            ],
          ),
          _selectedGenderSelf
              ? showFieldContent(_prefs.gender, 285.0, () {
                  setState(() {
                    _prefs.gender = '';
                    _selectedGenderSelf = false;
                  });
                })
              : Container(),
        ],
      ),
    );
  }

  Widget _initAge(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              "Date of Birth",
              style: TextStyle(
                color: Colors.white,
                fontSize: AppFontSizes.subTitleSize,
              ),
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            ),
          ),
          _showAgeContent(context),
        ],
      ),
    );
  }

  Widget _showAgeContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!_selectedAge) {
      return Row(
        children: [
          ActionCardAdd("add", "icon_plusButton.png", size, () {
            setState(() {
              // _showAgeDialog(context, () {
              //   setState(() {
              //     _selectedAge = _prefs.age.isEmpty ? false : true;
              //     Navigator.of(context).pop();
              //   });
              // });
              buildCupertinoDatePicker(context);
              // _selectDate(context);
            });
          }),
        ],
      );
    } else {
      return showFieldContent(_prefs.age, 250.0, () {
        setState(() {
          _prefs.age = '';
          _selectedAge = false;
        });
      });
    }
  }

  buildCupertinoDatePicker(BuildContext context) {
    DateTime now = DateTime.now();
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        context: context,
        builder: (BuildContext builder) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppColor.secondaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            height: MediaQuery.of(context).copyWith().size.height / 2.7,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    child: Text(
                      'Done',
                      style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w400),
                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Divider(
                  thickness: 1.0,
                  height: 0,
                  color: AppColor.primaryColor,
                ),
                Container(
                  height: MediaQuery.of(context).copyWith().size.height / 4,
                  color: Colors.white,
                  child: CupertinoDatePicker(
                    minimumDate: DateTime(now.year - 99),
                    // maximumDate: DateTime(now.year - 21),
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (picked) {
                      if (picked != currentDate)
                        setState(() {
                          currentDate = picked;
                          _selectedAge = true;
                          _prefs.age = DateFormat('yyyy-MM-dd').format(picked);
                        });
                    },
                    initialDateTime: DateTime(now.year - 21),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _initAllowActions() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Communications Preferences",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize + 2.5,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          Row(
            children: [
              Text(
                "Notifications while using the app",
                style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                width: 10.0,
              ),
              Switch(
                  value: _switchedNotifications,
                  activeColor: AppColor.secondaryColor,
                  onChanged: (value) {
                    setState(() {
                      _switchedNotifications = value;
                    });
                  })
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 220.0,
              child: Text(
                "Relevant insight, news & offers",
                style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              children: [
                Row(
                  children: [
                    Text(
                      "Email",
                      style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                    ),
                    SizedBox(width: 20.0),
                    Switch(
                        value: _prefs.marketingEmail,
                        activeColor: AppColor.secondaryColor,
                        onChanged: (value) {
                          setState(() {
                            _prefs.marketingEmail = value;
                          });
                        })
                  ],
                ),
                SizedBox(width: 30.0),
                Row(
                  children: [
                    Text(
                      "Text",
                      style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                    ),
                    SizedBox(width: 20.0),
                    Switch(
                        value: _prefs.marketingText,
                        activeColor: AppColor.secondaryColor,
                        onChanged: (value) {
                          setState(() {
                            _prefs.marketingText = value;
                          });
                        })
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAgeDialog(BuildContext context, VoidCallback callback) {
    _prefs.age = "";
    Dialog fancyDialog = Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        height: 250.0,
        width: 300.0,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Age",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(117, 148, 132, 1.0), width: 1.5),
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Done",
                      style: TextStyle(color: Color.fromRGBO(117, 148, 132, 1.0), fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                onTap: callback,
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 100.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Enter your age',
                            style: TextStyle(fontSize: 13.0, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20.0),
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(fontSize: 13.0, color: Colors.black),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "age",
                              hintStyle: TextStyle(fontSize: 13.0, color: Colors.grey[300]),
                              errorText: null, //"\u26A0 email incorrecto",
                              contentPadding: const EdgeInsets.only(left: 25.0, bottom: 10.0, top: 25.0),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                              errorStyle: TextStyle(fontSize: 11.0)),
                          onChanged: (value) {
                            _prefs.age = value;
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }

  void _showUserInformationDialog(BuildContext context, VoidCallback callback) {
    _prefs.firstname = "";
    _prefs.lastname = "";
    Dialog fancyDialog = Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        height: 320.0,
        width: 300.0,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Your Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Divider(
                        thickness: 1.0,
                        height: 0.0,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(height: 12.5),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Done",
                          style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: callback,
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 180.0,
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
                              contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 1.0)),
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
                              contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 1.0)),
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
                )),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }

  void _showUserNameDialog(BuildContext context, VoidCallback callback) {
    _prefs.username = "";
    Dialog fancyDialog = Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        height: 240.0,
        width: 300.0,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Username",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Divider(
                        thickness: 1.0,
                        height: 0.0,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(height: 12.5),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Done",
                          style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: callback,
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 100.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Choose a username",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Material(
                        elevation: 2.5,
                        borderRadius: BorderRadius.circular(20.0),
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "screen name",
                              hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                              errorText: null, //"\u26A0 email incorrecto",
                              contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                              errorStyle: TextStyle(fontSize: 11.0)),
                          onChanged: (value) {
                            _prefs.username = value;
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }

  void _showGenderSelfDescriptionDialog(BuildContext context, VoidCallback callback) {
    _prefs.gender = "";
    Dialog fancyDialog = Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        height: 240.0,
        width: 300.0,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Gender",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Divider(
                        thickness: 1.0,
                        height: 0.0,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(height: 12.5),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Done",
                          style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: callback,
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 100.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Self-Description",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Material(
                        elevation: 2.5,
                        borderRadius: BorderRadius.circular(20.0),
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "self-description",
                              hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                              errorText: null, //"\u26A0 email incorrecto",
                              contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                              errorStyle: TextStyle(fontSize: 11.0)),
                          onChanged: (value) {
                            _prefs.gender = value;
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }

  bool _validateProfile() {
    if (_prefs.firstname == "" && _prefs.lastname == "") {
      if (_prefs.username == "") {
        showAlertMessage(context, "Please complete your name or username to continue", () {
          Navigator.pop(context);
        });
        return false;
      }
    }

    // if (_prefs.gender == "") {
    //   showAlertMessage(context, "Please complete gender to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // } else if (_prefs.age == "") {
    //   showAlertMessage(context, "Please complete date of birth to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // } else if (_prefs.firstname == "" && _prefs.lastname == "") {
    //   if (_prefs.username == "") {
    //     showAlertMessage(context, "Please complete your name or username to continue", () {
    //       Navigator.pop(context);
    //     });
    //     return false;
    //   }
    // } else if (!_selectedEthnicity && _prefs.ethnnicity == "") {
    //   showAlertMessage(context, "Please complete Ethnnicity to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // } else if (!_selectedMaritalStatus && _prefs.maritalStatus == "") {
    //   showAlertMessage(context, "Please complete your marital status to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // } else if (!_selectedEmploymentStatus && _prefs.employmentStatus == "") {
    //   showAlertMessage(context, "Please complete your employment status to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // } else if (!_selectedEducation && _prefs.education == "") {
    //   showAlertMessage(context, "Please complete your level of education to continue", () {
    //     Navigator.pop(context);
    //   });
    // return false;
    // }

    return true;
  }

  void clearProfile() {
    _selectedUserName = false;
    _prefs.username = "";

    _selectedGenderMale = false;
    _selectedGenderFemale = false;
    _selectedGenderFluid = false;
    _selectedGenderSelf = false;
    _prefs.gender = "";

    _selectedAge = false;
    _prefs.age = "";

    _switchedNotifications = true;

    _selectedEthnicity = false;
    _prefs.ethnnicity = "";

    _selectedMaritalStatus = false;
    _prefs.maritalStatus = "";

    _selectedEmploymentStatus = false;
    _prefs.employmentStatus = "";

    _selectedEducation = false;
    _prefs.education = "";
  }

  _next(BuildContext context) async {
    if (_validateProfile()) {
      if (_prefs.username != "" && !_prefs.demoVersion) {
        ProgressDialog progressDialog = ProgressDialog(context);
        progressDialog.show();
        try {
          Map infoResponse = await userProfileServices.usernameVerification(_prefs.username);
          if (infoResponse['ok']) {
            progressDialog.dismiss();
            showAlertMessage(context, "Username already exists", () {
              Navigator.pop(context);
            });
          } else {
            progressDialog.dismiss();
            print('age: ${_prefs.email}');
            print('firstname: ${_prefs.firstname}');
            print('lastname: ${_prefs.lastname}');
            print('username: ${_prefs.username}');
            print('gender: ${_prefs.gender}');
            print('age: ${_prefs.age}');
            print('ethnnicity: ${_prefs.ethnnicity}');
            print('maritalStatus: ${_prefs.maritalStatus}');
            print('employmentStatus: ${_prefs.employmentStatus}');
            print('education: ${_prefs.education}');
            print('marketingEmail: ${_prefs.marketingEmail}');
            print('marketingText: ${_prefs.marketingText}');
            Navigator.pushNamed(context, 'onboarding_location');
          }
        } catch (e) {
          progressDialog.dismiss();
          showAlertMessage(context, "A network error occurred", () {
            Navigator.pop(context);
          });
          throw e;
        }
      } else {
        Navigator.pushNamed(context, 'onboarding_location');
      }
    }
  }

  Widget _initEthnicity(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ethnicity",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _selectedEthnicity
              ? showFieldContent(_prefs.ethnnicity, 250.0, () {
                  setState(() {
                    ethnicityList.forEach((e) {
                      e.isSelected = false;
                    });
                    _selectedEthnicity = false;
                    _prefs.ethnnicity = '';
                  });
                })
              : Row(
                  children: [
                    ActionCardAdd("add", "icon_plusButton.png", size, () {
                      setState(() {
                        _showEthnicityDialog(
                          context,
                          () {
                            ethnicityList.forEach((e) {
                              if (e.isSelected) {
                                _selectedEthnicity = true;
                                _prefs.ethnnicity = e.title!;
                              }
                            });
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        );
                      });
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  void _showEthnicityDialog(BuildContext context, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    Dialog fancyDialog = Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        height: 450.0,
        width: 300.0,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Ethnicity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 350.0,
                  padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "What would best describe you?",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ethnicityList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ethnicity = ethnicityList[index];
                            return StatefulBuilder(builder: (context, setState) {
                              return Card(
                                elevation: 2.5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  side: BorderSide(width: 1.5, color: Colors.transparent),
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
                                            ethnicity.title!,
                                            style: TextStyle(
                                                color: AppColor.content, fontSize: AppFontSizes.contentSize - 2.5, fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (ethnicity.isSelected) {
                                      ethnicity.isSelected = false;
                                    } else {
                                      ethnicityList.forEach((e) {
                                        e.isSelected = false;
                                      });
                                      ethnicity.isSelected = true;
                                    }
                                    callback();
                                  },
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }

  Widget _initMarital(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Marital Status",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _selectedMaritalStatus
              ? showFieldContent(_prefs.maritalStatus, 250.0, () {
                  setState(() {
                    maritalList.forEach((e) {
                      e.isSelected = false;
                    });
                    _selectedMaritalStatus = false;
                    _prefs.maritalStatus = '';
                  });
                })
              : Row(
                  children: [
                    ActionCardAdd("add", "icon_plusButton.png", size, () {
                      setState(() {
                        _showMaritalDialog(
                          context,
                          () {
                            maritalList.forEach((e) {
                              if (e.isSelected) {
                                _selectedMaritalStatus = true;
                                _prefs.maritalStatus = e.title!;
                              }
                            });
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        );
                      });
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  void _showMaritalDialog(BuildContext context, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    Dialog fancyDialog = Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        height: 400.0,
        width: 300.0,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Marital Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 310.0,
                  padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Select your current marital status",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: maritalList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final marital = maritalList[index];
                            return StatefulBuilder(builder: (context, setState) {
                              return Card(
                                elevation: 2.5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  side: BorderSide(width: 1.5, color: Colors.transparent),
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
                                            marital.title!,
                                            style: TextStyle(
                                                color: AppColor.content, fontSize: AppFontSizes.contentSize - 2.5, fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (marital.isSelected) {
                                      marital.isSelected = false;
                                    } else {
                                      maritalList.forEach((e) {
                                        e.isSelected = false;
                                      });
                                      marital.isSelected = true;
                                    }
                                    callback();
                                  },
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }

  Widget _initEmployment(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Employment Status",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _selectedEmploymentStatus
              ? showFieldContent(_prefs.employmentStatus, 250.0, () {
                  setState(() {
                    employmentList.forEach((e) {
                      e.isSelected = false;
                    });
                    _selectedEmploymentStatus = false;
                    _prefs.employmentStatus = '';
                  });
                })
              : Row(
                  children: [
                    ActionCardAdd("add", "icon_plusButton.png", size, () {
                      setState(() {
                        _showEmploymentDialog(
                          context,
                          () {
                            employmentList.forEach((e) {
                              if (e.isSelected) {
                                _selectedEmploymentStatus = true;
                                _prefs.employmentStatus = e.title!;
                              }
                            });
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        );
                      });
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  void _showEmploymentDialog(BuildContext context, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    Dialog fancyDialog = Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        height: 450.0,
        width: 300.0,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Employment Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 350.0,
                  padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Select your current employment status",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: employmentList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final employment = employmentList[index];
                            return StatefulBuilder(builder: (context, setState) {
                              return Card(
                                elevation: 2.5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  side: BorderSide(width: 1.5, color: Colors.transparent),
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
                                            employment.title!,
                                            style: TextStyle(
                                                color: AppColor.content, fontSize: AppFontSizes.contentSize - 2.5, fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (employment.isSelected) {
                                      employment.isSelected = false;
                                    } else {
                                      employmentList.forEach((e) {
                                        e.isSelected = false;
                                      });
                                      employment.isSelected = true;
                                    }
                                    callback();
                                  },
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }

  Widget _initEducation(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Highest Level of Education",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _selectedEducation
              ? showFieldContent(_prefs.education, 250.0, () {
                  setState(() {
                    educationList.forEach((e) {
                      e.isSelected = false;
                    });
                    _selectedEducation = false;
                    _prefs.education = '';
                  });
                })
              : Row(
                  children: [
                    ActionCardAdd("add", "icon_plusButton.png", size, () {
                      setState(() {
                        _showEducationDialog(
                          context,
                          () {
                            educationList.forEach((e) {
                              if (e.isSelected) {
                                _selectedEducation = true;
                                _prefs.education = e.title!;
                              }
                            });
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        );
                      });
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  void _showEducationDialog(BuildContext context, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    Dialog fancyDialog = Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        height: 320.0,
        width: 300.0,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Highest Level of Education",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 220.0,
                  padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Select your current level of education",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: educationList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final education = educationList[index];
                            return StatefulBuilder(builder: (context, setState) {
                              return Card(
                                elevation: 2.5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  side: BorderSide(width: 1.5, color: Colors.transparent),
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
                                            education.title!,
                                            style: TextStyle(
                                                color: AppColor.content, fontSize: AppFontSizes.contentSize - 2.5, fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (education.isSelected) {
                                      education.isSelected = false;
                                    } else {
                                      educationList.forEach((e) {
                                        e.isSelected = false;
                                      });
                                      education.isSelected = true;
                                    }
                                    callback();
                                  },
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }
}
