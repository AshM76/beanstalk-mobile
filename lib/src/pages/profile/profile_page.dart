import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:numberpicker/numberpicker.dart';

import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_symptom_model.dart';
import 'package:beanstalk_mobile/src/models/canna_therapeutic_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_additional_model.dart';
import 'package:beanstalk_mobile/src/services/user/user_profile_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/canna_medication_model.dart';
import 'package:beanstalk_mobile/src/utils/valueProfile_showalert.dart';
import 'package:beanstalk_mobile/src/widgets/appversion_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/actionCard_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_email_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_field_dataEmpty_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_fullName_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_phoneNumber_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_userName_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_dialog_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_field_infoEmpty_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_header_widget.dart';
import 'package:beanstalk_mobile/src/widgets/profile/profile_progressBar_widget.dart';

import '../../datas/app_data_locations.dart';
import '../../models/canna_measurement_model.dart';
import '../../models/locations/location_state_model.dart';
import '../../widgets/profile/lumir_study/lummir_selectAdditionalCondition_widget.dart';
import '../../widgets/profile/lumir_study/lummir_selectCondition_widget.dart';
import '../../widgets/profile/lumir_study/lummir_selectSecondaryCondition_widget.dart';
import '../../widgets/profile/lumir_study/profile_dialog_education_widget.dart';
import '../../widgets/profile/lumir_study/profile_dialog_employment_widget.dart';
import '../../widgets/profile/lumir_study/profile_dialog_ethnicity_widget.dart';
import '../../widgets/profile/lumir_study/profile_dialog_marital_widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  final _prefs = new UserPreference();
  final userProfileServices = UserProfileServices();

  int _indexScreen = 0;

  bool _selectedUS = false;
  bool _selectedAU = false;

  List<Condition> _conditionsPrimary = [];
  List<Condition> _conditionsSecondary = [];
  List<Additional> _conditionsAdditional = [];

  List<Medication> _medications = [];
  List<Therapeutic> _therapeutics = [];

  final List<Symptom> dataSympthoms = AppData.dataSympthoms;
  final List<Medication> dataMedications = AppData.dataMedications;

  final List<Medication> dataMedicationTherapeutics = AppData.dataMedications;
  final List<Medication> dataMedicationTherapeuticsNonCannabis = AppData.dataMedicationsNonCannabis;

  bool _selectParameterFirst = false;
  bool _selectParameterSecond = false;
  bool _selectParameterThird = false;

  bool _selectedPreferenceLoveIt = false;
  bool _selectedPreferenceLikeIt = false;
  bool _selectedPreferenceItsOk = false;

  bool _selectedExperienceBeginner = false;
  bool _selectedExperienceAlot = false;
  bool _selectedExperienceAlittle = false;
  bool _selectedExperienceExpert = false;

  bool editMode = false;

  bool _updateEmail = false;

  final List<int> dataNotificationTimes = AppData.dataNotificationTimes;

  bool _selectedDealsInhale = true;
  bool _selectedDealsVape = true;
  bool _selectedDealsTopical = true;
  bool _selectedDealsEdibles = true;
  bool _selectedDealsTinctures = true;
  bool _selectedDealsDabbing = true;

  final List<Measurement> _dataMeasurement = AppData.dataMeasurements;

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      loadProfile(context);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bloc = Provider.onboardingOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: SafeArea(
            child: Center(
              child: Image.network(
                AppLogos.iconImg,
                width: size.width * 0.1,
                height: size.width * 0.1,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        leading: editMode
            ? Container(
                width: 80.0,
                padding: EdgeInsets.only(right: 5.0, left: 15.0),
                child: IconButton(
                  icon: new Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: size.width * 0.1,
                  ),
                  onPressed: () {
                    print("> CANCEL");
                    setState(() {
                      editMode = false;
                      _updateEmail = false;
                      loadProfile(context);
                    });
                  },
                ),
              )
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColor.background,
                onPressed: () => Navigator.of(context).pop(),
              ),
        actions: <Widget>[
          editMode
              ? InkWell(
                  child: Container(
                    width: 80.0,
                    padding: EdgeInsets.only(left: 5.0, right: 15.0),
                    child: Center(
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  onTap: () async {
                    print("> SAVE");

                    List<Condition> tempPrimaryConditions = [];
                    _prefs.primaryConditions.forEach((condition) {
                      Map<String, dynamic> temp = jsonDecode(condition);
                      Condition tempCondition = Condition.fromJson(temp);
                      tempPrimaryConditions.add(tempCondition);
                    });
                    List<Condition> tempSecondaryConditions = [];
                    _prefs.secondaryConditions.forEach((condition) {
                      Map<String, dynamic> temp = jsonDecode(condition);
                      Condition tempCondition = Condition.fromJson(temp);
                      tempSecondaryConditions.add(tempCondition);
                    });
                    List<Additional> tempAdditionalConditions = [];
                    _prefs.additionalConditions.forEach((additional) {
                      Map<String, dynamic> temp = jsonDecode(additional);
                      Additional tempAdditional = Additional.fromJson(temp);
                      tempAdditionalConditions.add(tempAdditional);
                    });
                    List<Symptom> tempSymptoms = [];
                    _prefs.symptoms.forEach((symptom) {
                      Map<String, dynamic> temp = jsonDecode(symptom);
                      Symptom tempSymptom = Symptom.fromJson(temp);
                      tempSymptoms.add(tempSymptom);
                    });
                    List<Medication> tempMedications = [];
                    _prefs.medications.forEach((medication) {
                      Map<String, dynamic> temp = jsonDecode(medication);
                      Medication tempMedication = Medication.fromJson(temp);
                      tempMedications.add(tempMedication);
                    });
                    List<Therapeutic> tempTherapeutics = [];
                    _prefs.therapeutics.forEach((therapeutic) {
                      Map<String, dynamic> temp = jsonDecode(therapeutic);
                      Therapeutic tempTherapeutic = Therapeutic.fromJson(temp);
                      tempTherapeutics.add(tempTherapeutic);
                    });
                    final profileData = {
                      'patient_firstName': _prefs.firstname,
                      'patient_lastName': _prefs.lastname,
                      'patient_userName': _prefs.username,
                      'patient_gender': _prefs.gender,
                      'patient_age': _prefs.age != '' ? _prefs.age : null,
                      'patient_contact': {
                        'phone': _prefs.phonenumber,
                      },
                      'patient_ethnicity': _prefs.ethnnicity,
                      'patient_marital': _prefs.maritalStatus,
                      'patient_employment': _prefs.employmentStatus,
                      'patient_education': _prefs.education,
                      'patient_address': {
                        'country': _prefs.country,
                        'addressLine1': _prefs.street,
                        'city': _prefs.city,
                        'state': _prefs.state,
                        'zip': _prefs.zip,
                      },
                      'patient_height': _prefs.height,
                      'patient_height_metric': _prefs.heightMetric,
                      'patient_weight': _prefs.weight,
                      'patient_weight_metric': _prefs.weightMetric,
                      'patient_cigarettes': {
                        'cigarette_consume': _prefs.cigarettesConsume,
                        'cigarette_amountPerDay': _prefs.cigarettesAmount,
                      },
                      'patient_cannabis': {
                        'cannabis_consume': _prefs.cannabisConsume,
                        'cannabis_kindOfUse': _prefs.cannabisKind,
                        'cannabis_frequencyOfUse': _prefs.cannabisFrequency,
                      },
                      'patient_drugs': {
                        'drug_consume': _prefs.drugsConsume,
                        'drug_kindOfUse': _prefs.drugsKind,
                      },
                      'patient_primaryConditions': tempPrimaryConditions,
                      'patient_secondaryConditions': tempSecondaryConditions,
                      'patient_additionalConditions': tempAdditionalConditions,
                      'patient_symptoms': tempSymptoms,
                      'patient_medications': tempMedications,
                      'patient_therapeutics': tempTherapeutics,
                    };

                    if (_updateEmail) {
                      profileData['user_email'] = _prefs.email;
                      _prefs.validateEmail = false;
                    }

                    await updateProfile(context, profileData);
                    setState(() {});
                  },
                )
              : Container(
                  padding: EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: new Icon(
                      Icons.edit,
                      size: size.width * 0.09,
                      color: editMode ? AppColor.primaryColor : Colors.white,
                    ),
                    onPressed: () {
                      print("> EDIT MODE");
                      if (_prefs.demoVersion) {
                        showAlertMessage(context, 'Not available in demo version', () {
                          Navigator.pop(context);
                        });
                      } else {
                        setState(() {
                          editMode = true;
                        });
                      }
                    },
                  ),
                ),
          editMode
              ? Container()
              : Container(
                  padding: EdgeInsets.only(right: 20.0),
                  child: InkWell(
                      child: Image(
                        color: AppColor.secondaryColor,
                        width: size.width * 0.08,
                        image: AssetImage('assets/img/icon_signout.png'),
                        fit: BoxFit.contain,
                      ),
                      onTap: () {
                        print("::Logout");
                        showAlertMessageTwoAction(context, 210.0, "Logout", "Are you sure you want to logout?", "Confirm", "Cancel", () {
                          _prefs.logout();
                          Navigator.popAndPushNamed(context, 'signin');
                        }, () => Navigator.pop(context));
                      }),
                ),
        ],
      ),
      body: Container(
        color: AppColor.background,
        child: Stack(
          children: <Widget>[
            initProfileHeader(context),
            Positioned(
              right: -40.0,
              top: 60.0,
              child: Image.network(
                AppLogos.iconWhiteImg,
                height: 230.0,
                fit: BoxFit.contain,
                // color: Colors.white.withOpacity(0.1),
                opacity: const AlwaysStoppedAnimation(0.2),
              ),
            ),
            _initHeaderContent(context, _prefs),
            _initProfileContent(context, _prefs, bloc),
          ],
        ),
      ),
    );
  }

  loadProfile(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse = await userProfileServices.loadUserProfile(_prefs.id);
      if (infoResponse['ok']) {
        setState(() {
          progressDialog.dismiss();
          if (_prefs.valueProfile < 100) {
            valueProfileShowAlert(context, false);
          }
        });
      } else {
        showAlertMessage(context, "error load profile", () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      showAlertMessage(context, "A network error occurred", () {
        Navigator.pop(context);
      });
      throw e;
    }
  }

  updateProfile(BuildContext context, Map<String, dynamic> profile) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse = await userProfileServices.updateUserProfile(_prefs.id, profile);
      if (infoResponse['ok']) {
        setState(() {
          progressDialog.dismiss();
          editMode = false;
          _updateEmail = false;
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

  Widget _initHeaderContent(BuildContext context, UserPreference _prefs) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: size.height * 0.11,
      left: size.width * 0.07,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.025),
          Text(
            "About You",
            style: TextStyle(
              fontSize: AppFontSizes.titleSize + (size.width * 0.01),
              fontFamily: AppFont.primaryFont,
              color: AppColor.fourthColor,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              Image(
                color: AppColor.fifthColor,
                width: 11.0,
                image: AssetImage('assets/img/icon_arrow.png'),
                fit: BoxFit.contain,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                _prefs.screenName,
                style: TextStyle(fontSize: AppFontSizes.subTitleSize, color: Colors.white),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
            ],
          ),
          // SizedBox(height: size.height * 0.003),
          // Padding(
          //   padding: EdgeInsets.only(left: 20.0),
          //   child: Text(
          //     'Location',
          //     style: TextStyle(fontSize: 12, color: AppColor.fourthColor),
          //   ),
          // ),
          // SizedBox(height: size.height * 0.01),
          // Row(
          //   children: [
          //     Image(
          //       color: AppColor.fourthColor,
          //       width: 11.0,
          //       image: AssetImage('assets/img/icon_arrow.png'),
          //       fit: BoxFit.contain,
          //     ),
          //     SizedBox(width: size.width * 0.02),
          //     Text(
          //       '1800 pts',
          //       style: TextStyle(fontSize: 14, color: Colors.white),
          //     ),
          //   ],
          // ),
          SizedBox(height: size.height * 0.025),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
            child: initProfileProgressBar(context, size.width * 0.7, _prefs.valueProfile),
          ),
        ],
      ),
    );
  }

  Widget _initProfileContent(BuildContext context, UserPreference _prefs, OnboardingBloc bloc) {
    final size = MediaQuery.of(context).size;
    TabController _tabController = TabController(length: 6, initialIndex: _indexScreen, vsync: this);
    return Container(
      padding: EdgeInsets.only(
        top: size.height * 0.35,
        left: size.width * 0.06,
        right: size.width * 0.06,
      ),
      child: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(height: size.height * 0.01),
          Container(
            width: double.maxFinite,
            height: 50,
            child: TabBar(
              tabAlignment: TabAlignment.start,
              onTap: (index) {
                _indexScreen = index;
              },
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColor.secondaryColor,
              labelPadding: EdgeInsets.all(10.0),
              unselectedLabelColor: AppColor.content,
              indicatorColor: AppColor.secondaryColor,
              tabs: [
                Row(
                  children: [
                    Icon(Icons.person_pin_sharp),
                    SizedBox(width: 5.0),
                    Text("Profile"),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded),
                    SizedBox(width: 5.0),
                    Text("Location"),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.medical_services_rounded),
                    SizedBox(width: 5.0),
                    Text("Conditions"),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.medication_rounded),
                    SizedBox(width: 5.0),
                    Text("Therapeutics"),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.phonelink_setup_outlined),
                    SizedBox(width: 5.0),
                    Text("Settings"),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.lock_rounded),
                    SizedBox(width: 5.0),
                    Text("Security"),
                  ],
                ),
              ],
            ),
          ),
          Container(
              width: double.maxFinite,
              height: size.height * 0.5,
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(child: _initInformationProfile(context, _prefs, bloc)),
                  SingleChildScrollView(child: _initLocationgProfile(context, _prefs)),
                  SingleChildScrollView(child: _initConditionsProfile(context, _prefs)),
                  SingleChildScrollView(child: _initTherapeuticsProfile(context, _prefs)),
                  SingleChildScrollView(child: _initSettingProfile(context, _prefs)),
                  SingleChildScrollView(child: _initSecurityProfile(context, _prefs)),
                ],
              )),
          Container(
              height: size.height * 0.07,
              child: Stack(children: <Widget>[
                initAppVersion(context),
              ])),
        ],
      )),
    );
  }

  ///////////
  //INFORMATION PROFILE
  Widget _initInformationProfile(BuildContext context, UserPreference _prefs, OnboardingBloc bloc) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          _initEmail(context, bloc, size.width * 0.9),
          SizedBox(height: size.height * 0.01),
          _initFullName(size.width * 0.9),
          SizedBox(height: size.height * 0.01),
          _initUserName(context, size.width * 0.9),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _initGender(context, size.width * 0.33),
              SizedBox(width: size.width * 0.025),
              _initBirthday(size.width * 0.525),
            ],
          ),
          // SizedBox(height: size.height * 0.01),
          // _initPhoneNumber(context, bloc, size.width * 0.9),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _initHeight(context),
              SizedBox(width: size.width * 0.025),
              _initWeight(context),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          _initEthnicity(context),
          SizedBox(height: size.height * 0.01),
          _initMarital(context),
          SizedBox(height: size.height * 0.01),
          _initEmployment(context),
          SizedBox(height: size.height * 0.01),
          _initEducation(context),
          SizedBox(height: size.height * 0.02),
          Divider(height: 5.0, color: AppColor.primaryColor),
        ],
      ),
    );
  }

  Widget _initTitleField(BuildContext context, String title) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Image(
          color: AppColor.fifthColor,
          width: 11.0,
          image: AssetImage('assets/img/icon_arrow.png'),
          fit: BoxFit.contain,
        ),
        SizedBox(width: size.width * 0.02),
        Text(
          title,
          style: TextStyle(fontSize: AppFontSizes.contentSize + 1.0, color: AppColor.content),
          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
        ),
      ],
    );
  }

  Widget _initEmail(BuildContext context, OnboardingBloc bloc, double width) {
    return initInformationField(
      context,
      width,
      "email",
      "Email",
      _prefs.email,
      _prefs.validateEmail,
      "verificate",
      true,
      () {
        String lastEmail = _prefs.email;
        showEmailDialog(context, _prefs.email, bloc, () {
          print(">>>Update Email");
          bool email = bloc.email.isEmpty ? false : true;
          if (email) {
            setState(() {
              String newEmail = bloc.email;
              if (lastEmail != newEmail) {
                _updateEmail = true;
              }
              _prefs.email = bloc.email;
              Navigator.of(context).pop();
            });
          }
        });
      },
    );
  }

  Widget _initFullName(double width) {
    bool fullname = _prefs.firstname.isEmpty ? false : true;
    if (fullname) {
      return initInformationField(
        context,
        width,
        "username",
        "Full Name",
        "${_prefs.firstname} ${_prefs.lastname}",
        true,
        "privacity",
        true,
        () {
          showFullNameDialog(context, _prefs.firstname, _prefs.lastname, () {
            print(">>>Save Fullname");
            bool first = _prefs.firstname.isEmpty ? false : true;
            bool last = _prefs.lastname.isEmpty ? false : true;
            if (first & last) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "username", "Full Name", () {
        showFullNameDialog(context, "", "", () async {
          print(">>>Save Fullname");
          bool firstname = _prefs.firstname.isEmpty ? false : true;
          bool lastname = _prefs.lastname.isEmpty ? false : true;
          if (firstname && lastname) {
            final updateData = {
              'patient_firstName': _prefs.firstname,
              'patient_lastName': _prefs.lastname,
            };
            await updateProfile(context, updateData);
            Navigator.of(context).pop();
            setState(() {});
          }
        });
      });
    }
  }

  Widget _initUserName(BuildContext context, double width) {
    bool username = _prefs.username.isEmpty ? false : true;
    if (username) {
      return initInformationField(
        context,
        width,
        "username",
        "Username",
        _prefs.username,
        true,
        "privacity",
        true,
        () {
          showUserNameDialog(context, _prefs.username, () {
            print(">>>Update Username");
            bool username = _prefs.username.isEmpty ? false : true;
            if (username) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "username", "Username", () {
        showUserNameDialog(context, "", () async {
          print(">>>Save Username");
          bool username = _prefs.username.isEmpty ? false : true;
          if (username) {
            final updateData = {
              'patient_userName': _prefs.username,
            };
            await updateProfile(context, updateData);
            Navigator.of(context).pop();
            setState(() {});
          }
        });
      });
    }
  }

  Widget _initGender(BuildContext context, double width) {
    bool gender = _prefs.gender.isEmpty ? false : true;
    final size = MediaQuery.of(context).size;
    if (gender) {
      return Align(
        child: Container(
          width: width,
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: editMode ? Border.all(color: AppColor.fifthColor) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 25.0,
                              height: 25.0,
                              padding: EdgeInsets.only(left: size.width * 0.015),
                              child: _prefs.gender.isEmpty
                                  ? Container()
                                  : Image(
                                      color: editMode ? AppColor.content.withOpacity(0.25) : AppColor.primaryColor,
                                      image: AssetImage('assets/img/profile/${AppData().iconGender(_prefs.gender.toString())}'),
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              "Gender",
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: AppFontSizes.contentSmallSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.005),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Text(
                          _prefs.gender,
                          style: TextStyle(
                            color: AppColor.content,
                            fontSize: AppFontSizes.contentSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.01),
              editMode
                  ? InkWell(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 20.0,
                          width: 20.0,
                          margin: EdgeInsets.only(top: 2.5, right: 2.5),
                          decoration: BoxDecoration(
                            color: AppColor.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 12.0,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showGenderDialog(context, (gender) async {
                          if (gender.isNotEmpty) {
                            setState(() {
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      },
                    )
                  : Container(),
            ],
          ),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size.width * 0.275,
            height: 55.0,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 30.0,
                  margin: EdgeInsets.all(size.width * 0.02),
                  child: Image(
                    color: AppColor.content.withOpacity(0.25),
                    image: AssetImage('assets/img/profile/icon_profile_male.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gender",
                          style: TextStyle(
                            color: AppColor.content.withOpacity(0.5),
                            fontSize: AppFontSizes.contentSize - 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.01),
          Card(
            elevation: 1.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              child: SizedBox(
                width: size.width * 0.12,
                height: 55.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 2.5),
                      Image(
                        height: 25.0,
                        width: 25.0,
                        image: AssetImage('assets/img/icon_plusButton.png'),
                        fit: BoxFit.contain,
                        color: AppColor.thirdColor,
                      ),
                      SizedBox(height: 2.0),
                      Container(
                        height: 15.0,
                        width: 37.5,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.grey[600], fontSize: 10.0, fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                _showGenderDialog(context, (gender) async {
                  if (gender.isNotEmpty) {
                    final updateData = {
                      'patient_gender': _prefs.gender,
                    };
                    await updateProfile(context, updateData);
                    Navigator.of(context).pop();
                    setState(() {});
                  }
                });
              },
            ),
          ),
        ],
      );
    }
  }

  void _showGenderDialog(BuildContext context, Function(String gender) callback) {
    final size = MediaQuery.of(context).size;
    bool _selectedGenderMale = _prefs.gender == 'male' ? true : false;
    bool _selectedGenderFemale = _prefs.gender == 'female' ? true : false;
    bool _selectedGenderFluid = _prefs.gender == 'fluid' ? true : false;
    bool _selectedGenderSelf = false;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom / 1.25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 320 + (MediaQuery.of(context).viewInsets.bottom / 1.25),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    if (_prefs.gender != '') {
                                      callback(_prefs.gender);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 160.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Select your gender",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 15.0),
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
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

  Widget _initBirthday(double width) {
    bool age = _prefs.age.isEmpty ? false : true;
    final size = MediaQuery.of(context).size;
    if (age) {
      return initInformationField(
        context,
        width,
        "age",
        "Birthday",
        _prefs.age,
        true,
        "agevalidate",
        true,
        () {
          _showBirthdayDialog(context, (age) async {
            if (age.isNotEmpty) {
              Navigator.of(context).pop();
              setState(() {});
            }
          });
        },
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size.width * 0.275,
            height: 55.0,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 30.0,
                  margin: EdgeInsets.all(size.width * 0.02),
                  child: Image(
                    color: AppColor.content.withOpacity(0.25),
                    image: AssetImage('assets/img/profile/icon_profile_age.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Birthday",
                          style: TextStyle(
                            color: AppColor.content.withOpacity(0.5),
                            fontSize: AppFontSizes.contentSize - 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.01),
          Card(
            elevation: 1.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              child: SizedBox(
                width: size.width * 0.12,
                height: 55.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 2.5),
                      Image(
                        height: 25.0,
                        width: 25.0,
                        image: AssetImage('assets/img/icon_plusButton.png'),
                        fit: BoxFit.contain,
                        color: AppColor.thirdColor,
                      ),
                      SizedBox(height: 2.0),
                      Container(
                        height: 15.0,
                        width: 37.5,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.grey[600], fontSize: 10.0, fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                _showBirthdayDialog(context, (age) async {
                  if (age.isNotEmpty) {
                    final updateData = {
                      'patient_age': _prefs.age,
                    };
                    await updateProfile(context, updateData);
                    Navigator.of(context).pop();
                    setState(() {});
                  }
                });
              },
            ),
          ),
        ],
      );
    }
  }

  void _showBirthdayDialog(BuildContext context, Function(String age) callback) {
    final size = MediaQuery.of(context).size;
    DateTime now = DateTime.now();
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom / 1.25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 400 + (MediaQuery.of(context).viewInsets.bottom / 1.25),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    if (_prefs.age != '') {
                                      callback(_prefs.age);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 250.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Select your Birthday",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 15.0),
                                Divider(
                                  thickness: 1.0,
                                  height: 0,
                                  color: AppColor.primaryColor,
                                ),
                                Container(
                                  height: MediaQuery.of(context).copyWith().size.height / 4,
                                  color: Colors.transparent,
                                  child: CupertinoDatePicker(
                                    minimumDate: DateTime(now.year - 99),
                                    // maximumDate: DateTime(now.year - 21),
                                    mode: CupertinoDatePickerMode.date,
                                    onDateTimeChanged: (picked) {
                                      if (picked != now)
                                        setState(() {
                                          now = picked;
                                          _prefs.age = DateFormat('yyyy-MM-dd').format(picked);
                                        });
                                    },
                                    initialDateTime: DateTime(now.year - 21),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  Widget _initPhoneNumber(BuildContext context, OnboardingBloc bloc, double width) {
    bool phonenumber = _prefs.phonenumber.isEmpty ? false : true;
    if (phonenumber) {
      return initInformationField(
        context,
        width,
        "phone",
        "Phone Number",
        _prefs.phonenumber,
        true,
        "verificate",
        true,
        () {
          showPhoneNumberDialog(context, _prefs.phonenumber, bloc, () {
            print(">>>Phone Number");
            int phonenumber = bloc.phonenumber.length;
            if (phonenumber == 14) {
              setState(() {
                _prefs.phonenumber = bloc.phonenumber;
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "phone", "Phone Number", () {
        showPhoneNumberDialog(context, "", bloc, () async {
          print(">>>Phone Number");
          int phonenumber = bloc.phonenumber.length;
          if (phonenumber == 14) {
            _prefs.phonenumber = bloc.phonenumber;
            final updateData = {
              'patient_contact': {'phone': _prefs.phonenumber},
            };
            await updateProfile(context, updateData);
            Navigator.of(context).pop();
            setState(() {});
          }
        });
      });
    }
  }

  Widget _initEthnicity(BuildContext context) {
    bool ethnicity = _prefs.ethnnicity.isEmpty ? false : true;
    if (ethnicity) {
      return initAditionalInformationField(
        context,
        "Ethnicity",
        _prefs.ethnnicity,
        () {
          showEthnicityDialog(context, _prefs.ethnnicity, () {
            if (_prefs.ethnnicity.isNotEmpty) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "username", "Ethnicity", () {
        showEthnicityDialog(context, "", () async {
          if (_prefs.ethnnicity.isNotEmpty) {
            final updateData = {
              'patient_ethnicity': _prefs.ethnnicity,
            };
            await updateProfile(context, updateData);
            Navigator.of(context).pop();
            setState(() {});
          }
        });
      });
    }
  }

  Widget _initMarital(BuildContext context) {
    bool marital = _prefs.maritalStatus.isEmpty ? false : true;
    if (marital) {
      return initAditionalInformationField(
        context,
        "Marital Status",
        _prefs.maritalStatus,
        () {
          showMaritalDialog(context, _prefs.maritalStatus, () {
            if (_prefs.maritalStatus.isNotEmpty) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "username", "Marital Status", () {
        showMaritalDialog(context, "", () async {
          if (_prefs.maritalStatus.isNotEmpty) {
            final updateData = {
              'patient_marital': _prefs.maritalStatus,
            };
            await updateProfile(context, updateData);
            Navigator.of(context).pop();
            setState(() {});
          }
        });
      });
    }
  }

  Widget _initEmployment(BuildContext context) {
    bool employment = _prefs.employmentStatus.isEmpty ? false : true;
    if (employment) {
      return initAditionalInformationField(
        context,
        "Employment Status",
        _prefs.employmentStatus,
        () {
          showEmploymentDialog(context, _prefs.employmentStatus, () {
            if (_prefs.employmentStatus.isNotEmpty) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "username", "Employment Status", () {
        showEmploymentDialog(context, "", () async {
          if (_prefs.employmentStatus.isNotEmpty) {
            final updateData = {
              'patient_employment': _prefs.employmentStatus,
            };
            await updateProfile(context, updateData);
            Navigator.of(context).pop();
            setState(() {});
          }
        });
      });
    }
  }

  Widget _initEducation(BuildContext context) {
    bool education = _prefs.education.isEmpty ? false : true;
    if (education) {
      return initAditionalInformationField(
        context,
        "Highest Level of Education",
        _prefs.education,
        () {
          showEducationDialog(context, _prefs.education, () {
            if (_prefs.education.isNotEmpty) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "username", "Highest Level of Education", () {
        showEducationDialog(context, "", () async {
          if (_prefs.education.isNotEmpty) {
            final updateData = {
              'patient_education': _prefs.education,
            };
            await updateProfile(context, updateData);
            Navigator.of(context).pop();
            setState(() {});
          }
        });
      });
    }
  }

  //Height Weight Metrics
  Widget _initHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool height = _prefs.height.isEmpty ? false : true;
    if (height) {
      return Expanded(
        child: Container(
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: editMode ? Border.all(color: AppColor.fifthColor) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 25.0,
                              height: 25.0,
                              padding: EdgeInsets.only(left: size.width * 0.015, top: size.height * 0.004, bottom: size.height * 0.004),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                                child: Icon(
                                  Icons.height,
                                  color: Colors.white,
                                  size: 15.0,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              "Height",
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: AppFontSizes.contentSmallSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.005),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Text(
                          _heightString(_prefs.height),
                          style: TextStyle(
                            color: AppColor.content,
                            fontSize: AppFontSizes.contentSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.01),
              editMode
                  ? InkWell(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 20.0,
                          width: 20.0,
                          margin: EdgeInsets.only(top: 2.5, right: 2.5),
                          decoration: BoxDecoration(
                            color: AppColor.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 12.0,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showHeightMetricDialog(context, (
                          height,
                          heightMetric,
                        ) async {
                          if (height > 0 && heightMetric.isNotEmpty) {
                            setState(() {
                              _prefs.height = height.toString();
                              _prefs.heightMetric = heightMetric;
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      },
                    )
                  : Container(),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            width: size.width * 0.75,
            height: 60.0,
            decoration: BoxDecoration(
              gradient: AppColor.secondaryGradient,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20.0,
                  left: size.width * 0.035,
                  child: Text(
                    'Height',
                    style: TextStyle(
                      color: AppColor.background,
                      fontSize: AppFontSizes.buttonSize + 5.0,
                    ),
                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                  ),
                ),
                Positioned(
                  top: 3.0,
                  left: size.width * 0.025,
                  child: Text(
                    'Height',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.1),
                      fontWeight: FontWeight.w900,
                      fontSize: AppFontSizes.buttonSize + 15.0,
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    width: size.width * 0.75,
                    padding: EdgeInsets.only(top: size.width * 0.04, bottom: size.width * 0.04, left: size.width * 0.27),
                    child: Image(image: AssetImage('assets/img/icon_plusButton.png'), color: AppColor.background),
                  ),
                  onTap: () {
                    _showHeightMetricDialog(context, (
                      height,
                      heightMetric,
                    ) async {
                      if (height > 0 && heightMetric.isNotEmpty) {
                        final updateData = {
                          'patient_height': height.toString(),
                          'patient_height_metric': heightMetric,
                        };
                        await updateProfile(context, updateData);
                        Navigator.of(context).pop();
                        setState(() {});
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  String _heightString(String height) {
    if (_prefs.country == 'US') {
      int? feets = int.tryParse(double.parse(height).toString().split('.')[0]);
      int inchesInFeets = int.tryParse(double.parse(height).toStringAsFixed(2).split('.')[1])!;
      if (inchesInFeets > 0) {
        String inches = inchesInFeets.toString().padLeft(3, "0.");
        String inchesValue = (double.parse(inches) * 12).toStringAsFixed(0);
        return feets.toString() + ' feet ' + inchesValue + ' inches';
      } else {
        return feets.toString() + ' feet';
      }
    } else {
      return double.parse(height).toStringAsFixed(0) + ' meters';
    }
  }

  Widget _initWeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool weight = _prefs.weight.isEmpty ? false : true;
    if (weight) {
      return Expanded(
        child: Container(
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: editMode ? Border.all(color: AppColor.fifthColor) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 25.0,
                              height: 25.0,
                              padding: EdgeInsets.only(left: size.width * 0.015, top: size.height * 0.004, bottom: size.height * 0.004),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                                child: Icon(
                                  Icons.monitor_weight,
                                  color: Colors.white,
                                  size: 15.0,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              "Weight",
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: AppFontSizes.contentSmallSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.005),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Text(
                          _weightString(_prefs.weight),
                          style: TextStyle(
                            color: AppColor.content,
                            fontSize: AppFontSizes.contentSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.01),
              editMode
                  ? InkWell(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 20.0,
                          width: 20.0,
                          margin: EdgeInsets.only(top: 2.5, right: 2.5),
                          decoration: BoxDecoration(
                            color: AppColor.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 12.0,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showWeightMetricDialog(context, (
                          weight,
                          weightMetric,
                        ) async {
                          if (weight > 0 && weightMetric.isNotEmpty) {
                            setState(() {
                              _prefs.weight = weight.toString();
                              _prefs.weightMetric = weightMetric;
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      },
                    )
                  : Container(),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            width: size.width * 0.75,
            height: 60.0,
            decoration: BoxDecoration(
              gradient: AppColor.secondaryGradient,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20.0,
                  left: size.width * 0.035,
                  child: Text(
                    'Weight',
                    style: TextStyle(
                      color: AppColor.background,
                      fontSize: AppFontSizes.buttonSize + 5.0,
                    ),
                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                  ),
                ),
                Positioned(
                  top: 3.0,
                  left: size.width * 0.025,
                  child: Text(
                    'Weight',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.1),
                      fontWeight: FontWeight.w900,
                      fontSize: AppFontSizes.buttonSize + 15.0,
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    width: size.width * 0.75,
                    padding: EdgeInsets.only(top: size.width * 0.04, bottom: size.width * 0.04, left: size.width * 0.27),
                    child: Image(image: AssetImage('assets/img/icon_plusButton.png'), color: AppColor.background),
                  ),
                  onTap: () {
                    _showWeightMetricDialog(context, (
                      weight,
                      weightMetric,
                    ) async {
                      if (weight > 0 && weightMetric.isNotEmpty) {
                        final updateData = {
                          'patient_weight': weight.toString(),
                          'patient_weight_metric': weightMetric,
                        };
                        await updateProfile(context, updateData);
                        Navigator.of(context).pop();
                        setState(() async {});
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  String _weightString(String weight) {
    if (_prefs.country == 'US') {
      int? lbs = int.tryParse(double.parse(weight).toString().split('.')[0]);
      int ozInLbs = int.tryParse(double.parse(weight).toStringAsFixed(4).split('.')[1])!;
      if (ozInLbs > 0) {
        String oz = ozInLbs.toString().padLeft(5, "0.");
        String ozValue = (double.parse(oz) / 0.0625).toStringAsFixed(0);
        return lbs.toString() + ' lbs ' + ozValue + ' oz';
      } else {
        return lbs.toString() + ' lbs';
      }
    } else {
      return double.parse(weight).toStringAsFixed(0) + ' kilograms';
    }
  }

  void _showHeightMetricDialog(BuildContext context, Function(double height, String heightMetric) callback) {
    final size = MediaQuery.of(context).size;
    TextEditingController? _feetController;
    TextEditingController? _inchesController;
    TextEditingController? _meterController;
    double _valueInFeets = 0;
    double _valueInInches = 0;
    double _valueInMeters = 0;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom / 1.25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 320 + (MediaQuery.of(context).viewInsets.bottom / 1.25),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    double heightValue = 0;
                                    String heightMetric = '';
                                    if (_prefs.country == 'US') {
                                      if (_valueInFeets > 0) {
                                        heightValue = _valueInFeets;
                                        heightMetric = 'feet';
                                        if (_valueInInches > 0) {
                                          heightValue += _valueInInches / 12;
                                          heightMetric = 'feet/inches';
                                        }
                                        callback(heightValue, heightMetric);
                                      }
                                    } else {
                                      if (_valueInMeters > 0) {
                                        heightValue = _valueInMeters;
                                        heightMetric = 'meters';
                                        callback(heightValue, heightMetric);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 160.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Enter your height measurement",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 15.0),
                                _prefs.country == 'US'
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Material(
                                                  elevation: 2.5,
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(size.width * 0.025), bottomLeft: Radius.circular(size.width * 0.025)),
                                                  child: Container(
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(size.width * 0.025),
                                                          bottomLeft: Radius.circular(size.width * 0.025)),
                                                      gradient: AppColor.secondaryGradient,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.5),
                                                          offset: Offset(1.0, 1.0), //(x,y)
                                                          blurRadius: 1.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Feet',
                                                        style: TextStyle(
                                                          fontSize: AppFontSizes.contentSize,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Material(
                                                  elevation: 2.5,
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(size.width * 0.025),
                                                      bottomRight: Radius.circular(size.width * 0.025)),
                                                  child: TextField(
                                                    autofocus: false,
                                                    controller: _feetController,
                                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                    keyboardType: TextInputType.number,
                                                    textCapitalization: TextCapitalization.sentences,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        hintText: 'feet',
                                                        hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                        errorText: null, //"\u26A0 email incorrecto",
                                                        contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide.none,
                                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                                        ),
                                                        border: OutlineInputBorder(
                                                            borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                            borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                        errorStyle: TextStyle(fontSize: 11.0)),
                                                    onChanged: (value) {
                                                      _valueInFeets = double.parse(value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.015),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Material(
                                                  elevation: 2.5,
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(size.width * 0.025), bottomLeft: Radius.circular(size.width * 0.025)),
                                                  child: Container(
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(size.width * 0.025),
                                                          bottomLeft: Radius.circular(size.width * 0.025)),
                                                      gradient: AppColor.secondaryGradient,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.5),
                                                          offset: Offset(1.0, 1.0), //(x,y)
                                                          blurRadius: 1.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Inches',
                                                        style: TextStyle(
                                                          fontSize: AppFontSizes.contentSize,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Material(
                                                  elevation: 2.5,
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(size.width * 0.025),
                                                      bottomRight: Radius.circular(size.width * 0.025)),
                                                  child: TextField(
                                                    autofocus: false,
                                                    controller: _inchesController,
                                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                    keyboardType: TextInputType.number,
                                                    textCapitalization: TextCapitalization.sentences,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        hintText: 'inches',
                                                        hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                        errorText: null, //"\u26A0 email incorrecto",
                                                        contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide.none,
                                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                                        ),
                                                        border: OutlineInputBorder(
                                                            borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                            borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                        errorStyle: TextStyle(fontSize: 11.0)),
                                                    onChanged: (value) {
                                                      _valueInInches = double.parse(value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Material(
                                              elevation: 2.5,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(size.width * 0.025), bottomLeft: Radius.circular(size.width * 0.025)),
                                              child: Container(
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(size.width * 0.025), bottomLeft: Radius.circular(size.width * 0.025)),
                                                  gradient: AppColor.secondaryGradient,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      offset: Offset(1.0, 1.0), //(x,y)
                                                      blurRadius: 1.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Meter',
                                                    style: TextStyle(
                                                      fontSize: AppFontSizes.contentSize,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Material(
                                              elevation: 2.5,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(size.width * 0.025), bottomRight: Radius.circular(size.width * 0.025)),
                                              child: TextField(
                                                autofocus: false,
                                                controller: _meterController,
                                                style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                keyboardType: TextInputType.number,
                                                textCapitalization: TextCapitalization.sentences,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    hintText: 'meter',
                                                    hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                    errorText: null, //"\u26A0 email incorrecto",
                                                    contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide.none,
                                                      borderRadius: BorderRadius.circular(size.width * 0.025),
                                                    ),
                                                    border: OutlineInputBorder(
                                                        borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                        borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                    errorStyle: TextStyle(fontSize: 11.0)),
                                                onChanged: (value) {
                                                  _valueInMeters = double.parse(value);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  void _showWeightMetricDialog(BuildContext context, Function(double height, String heightMetric) callback) {
    final size = MediaQuery.of(context).size;
    TextEditingController? _lbsController;
    TextEditingController? _ozController;
    TextEditingController? _kilogramsController;
    double _valueInLbs = 0;
    double _valueInOz = 0;
    double _valueInKilograms = 0;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom / 1.25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 320 + (MediaQuery.of(context).viewInsets.bottom / 1.25),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    double weightValue = 0;
                                    String weightMetric = '';
                                    if (_prefs.country == 'US') {
                                      if (_valueInLbs > 0) {
                                        weightValue = _valueInLbs;
                                        weightMetric = 'lbs';
                                        if (_valueInOz > 0) {
                                          weightValue += _valueInOz / 16;
                                          weightMetric = 'lbs/oz';
                                        }
                                        callback(weightValue, weightMetric);
                                      }
                                    } else {
                                      if (_valueInKilograms > 0) {
                                        weightValue = _valueInKilograms;
                                        weightMetric = 'kilograms';
                                        callback(weightValue, weightMetric);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 160.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Enter your weight measurement",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 15.0),
                                _prefs.country == 'US'
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Material(
                                                  elevation: 2.5,
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(size.width * 0.025), bottomLeft: Radius.circular(size.width * 0.025)),
                                                  child: Container(
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(size.width * 0.025),
                                                          bottomLeft: Radius.circular(size.width * 0.025)),
                                                      gradient: AppColor.secondaryGradient,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.5),
                                                          offset: Offset(1.0, 1.0), //(x,y)
                                                          blurRadius: 1.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Lbs',
                                                        style: TextStyle(
                                                          fontSize: AppFontSizes.contentSize,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Material(
                                                  elevation: 2.5,
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(size.width * 0.025),
                                                      bottomRight: Radius.circular(size.width * 0.025)),
                                                  child: TextField(
                                                    autofocus: false,
                                                    controller: _lbsController,
                                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                    keyboardType: TextInputType.number,
                                                    textCapitalization: TextCapitalization.sentences,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        hintText: 'lbs',
                                                        hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                        errorText: null, //"\u26A0 email incorrecto",
                                                        contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide.none,
                                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                                        ),
                                                        border: OutlineInputBorder(
                                                            borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                            borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                        errorStyle: TextStyle(fontSize: 11.0)),
                                                    onChanged: (value) {
                                                      _valueInLbs = double.parse(value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.015),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Material(
                                                  elevation: 2.5,
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(size.width * 0.025), bottomLeft: Radius.circular(size.width * 0.025)),
                                                  child: Container(
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(size.width * 0.025),
                                                          bottomLeft: Radius.circular(size.width * 0.025)),
                                                      gradient: AppColor.secondaryGradient,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.5),
                                                          offset: Offset(1.0, 1.0), //(x,y)
                                                          blurRadius: 1.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Oz',
                                                        style: TextStyle(
                                                          fontSize: AppFontSizes.contentSize,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Material(
                                                  elevation: 2.5,
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(size.width * 0.025),
                                                      bottomRight: Radius.circular(size.width * 0.025)),
                                                  child: TextField(
                                                    autofocus: false,
                                                    controller: _ozController,
                                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                    keyboardType: TextInputType.number,
                                                    textCapitalization: TextCapitalization.sentences,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        hintText: 'oz',
                                                        hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                        errorText: null, //"\u26A0 email incorrecto",
                                                        contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide.none,
                                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                                        ),
                                                        border: OutlineInputBorder(
                                                            borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                            borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                        errorStyle: TextStyle(fontSize: 11.0)),
                                                    onChanged: (value) {
                                                      _valueInOz = double.parse(value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Material(
                                              elevation: 2.5,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(size.width * 0.025), bottomLeft: Radius.circular(size.width * 0.025)),
                                              child: Container(
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(size.width * 0.025), bottomLeft: Radius.circular(size.width * 0.025)),
                                                  gradient: AppColor.secondaryGradient,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      offset: Offset(1.0, 1.0), //(x,y)
                                                      blurRadius: 1.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Kilograms',
                                                    style: TextStyle(
                                                      fontSize: AppFontSizes.contentSize,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Material(
                                              elevation: 2.5,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(size.width * 0.025), bottomRight: Radius.circular(size.width * 0.025)),
                                              child: TextField(
                                                autofocus: false,
                                                controller: _kilogramsController,
                                                style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                keyboardType: TextInputType.number,
                                                textCapitalization: TextCapitalization.sentences,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    hintText: 'kilograms',
                                                    hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                    errorText: null, //"\u26A0 email incorrecto",
                                                    contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide.none,
                                                      borderRadius: BorderRadius.circular(size.width * 0.025),
                                                    ),
                                                    border: OutlineInputBorder(
                                                        borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                        borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                    errorStyle: TextStyle(fontSize: 11.0)),
                                                onChanged: (value) {
                                                  _valueInKilograms = double.parse(value);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  ///////////
  //CONDITIONS PROFILE
  Widget _initConditionsProfile(BuildContext context, UserPreference _prefs) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          _initPrimaryConditions(context),
          SizedBox(height: size.height * 0.01),
          _initSecondaryConditions(context),
          SizedBox(height: size.height * 0.01),
          _initAdditionalConditions(context),
          SizedBox(height: size.height * 0.02),
          Divider(height: 5.0, color: AppColor.primaryColor),
        ],
      ),
    );
  }

  Widget _initPrimaryConditions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _conditionsPrimary = [];
    _prefs.primaryConditions.forEach((condition) {
      Map<String, dynamic> temp = jsonDecode(condition);
      Condition tempCondition = Condition.fromJson(temp);
      _conditionsPrimary.add(tempCondition);
    });
    return Align(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.025, vertical: size.width * 0.001),
        child: Column(
          children: [
            _initTitleField(context, "Primary Conditions"),
            SizedBox(height: 5.0),
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: size.height * 0.1,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: _conditionsPrimary.length,
                          itemBuilder: (BuildContext context, int index) {
                            final condition = _conditionsPrimary[index];
                            return Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: editMode ? Border.all(color: AppColor.fifthColor) : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: size.height * 0.01),
                                      Image(
                                        color: AppColor.primaryColor,
                                        width: size.width * 0.125,
                                        height: size.height * 0.075,
                                        image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: size.height * 0.01),
                                      Container(
                                        width: size.width * 0.6,
                                        child: Center(
                                          child: Text(
                                            condition.title!,
                                            style:
                                                TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                editMode
                                    ? Positioned(
                                        top: 5.0,
                                        right: 0,
                                        child: InkWell(
                                          child: Container(
                                            height: 20.0,
                                            width: 20.0,
                                            decoration: BoxDecoration(
                                              color: AppColor.secondaryColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 12.0,
                                            ),
                                          ),
                                          onTap: () {
                                            showSelectConditionDialog(context, _conditionsPrimary, setState, (primaryConditions) {
                                              _conditionsPrimary = primaryConditions;
                                              List<String> conditionsEncoded =
                                                  _conditionsPrimary.map((condition) => jsonEncode(condition.toJson())).toList();
                                              _prefs.primaryConditions = [];
                                              _prefs.primaryConditions = conditionsEncoded;

                                              _conditionsSecondary = [];
                                              _prefs.secondaryConditions.forEach((condition) {
                                                Map<String, dynamic> temp = jsonDecode(condition);
                                                Condition tempCondition = Condition.fromJson(temp);
                                                _conditionsSecondary.add(tempCondition);
                                              });
                                              _conditionsSecondary.removeWhere((tempCondition) => tempCondition.title == _conditionsPrimary[0].title);
                                              List<String> conditionsSecondaryEncoded =
                                                  _conditionsSecondary.map((condition) => jsonEncode(condition.toJson())).toList();
                                              _prefs.secondaryConditions = [];
                                              _prefs.secondaryConditions = conditionsSecondaryEncoded;

                                              Navigator.of(context).pop();
                                              setState(() {});
                                            });
                                          },
                                        ),
                                      )
                                    : Container(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _initSecondaryConditions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _conditionsSecondary = [];
    _prefs.secondaryConditions.forEach((condition) {
      Map<String, dynamic> temp = jsonDecode(condition);
      Condition tempCondition = Condition.fromJson(temp);
      _conditionsSecondary.add(tempCondition);
    });

    if (_conditionsSecondary.length > 0) {
      return Align(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.025, vertical: size.width * 0.001),
          child: Column(
            children: [
              _initTitleField(context, "Secondary Conditions"),
              SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 120.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: _conditionsSecondary.length,
                            itemBuilder: (BuildContext context, int index) {
                              final condition = _conditionsSecondary[index];
                              return Stack(
                                children: [
                                  Container(
                                    width: size.width * 0.23,
                                    padding: EdgeInsets.all(5.0),
                                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: size.height * 0.005),
                                        Image(
                                          color: AppColor.primaryColor,
                                          width: size.width * 0.2,
                                          height: size.height * 0.05,
                                          image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        Container(
                                          width: size.width * 0.23,
                                          height: size.height * 0.03,
                                          child: Center(
                                            child: Text(
                                              condition.title!,
                                              style: TextStyle(
                                                  color: AppColor.content,
                                                  fontSize: condition.title!.length >= 10 ? size.width * 0.025 : size.width * 0.03,
                                                  fontWeight: FontWeight.w600),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  editMode
                                      ? Positioned(
                                          top: 5.0,
                                          left: (size.width * 0.2) - 10.0,
                                          child: InkWell(
                                            child: Container(
                                              height: 20.0,
                                              width: 20.0,
                                              decoration: BoxDecoration(
                                                color: AppColor.secondaryColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12.0,
                                              ),
                                            ),
                                            onTap: () {
                                              print("> Delete Condition");
                                              setState(() {
                                                _conditionsSecondary.removeWhere((e) => e.title == condition.title);

                                                List<String> conditionsEncoded =
                                                    _conditionsSecondary.map((condition) => jsonEncode(condition.toJson())).toList();

                                                _prefs.secondaryConditions = conditionsEncoded;
                                              });
                                            },
                                          ),
                                        )
                                      : Container(),
                                ],
                              );
                            },
                          ),
                        ),
                        _conditionsSecondary.length > 3
                            ? Positioned(
                                right: 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25.0),
                                      bottomLeft: Radius.circular(25.0),
                                    ),
                                  ),
                                  height: 120.0,
                                  width: size.width * 0.06,
                                  child: Center(
                                    child: Image(
                                      color: AppColor.background,
                                      width: 15.0,
                                      image: AssetImage('assets/img/icon_arrowButton.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  editMode
                      ? Container(
                          child: Card(
                            elevation: 1.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: editMode ? AppColor.fifthColor : Colors.black,
                                )),
                            child: InkWell(
                              child: SizedBox(
                                width: size.width * 0.12,
                                height: 100.0,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 2.5),
                                      Image(
                                        height: 25.0,
                                        width: 25.0,
                                        image: AssetImage('assets/img/icon_plusButton.png'),
                                        fit: BoxFit.contain,
                                        color: AppColor.thirdColor,
                                      ),
                                      SizedBox(height: 2.0),
                                      Container(
                                        height: 15.0,
                                        width: 37.5,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            'Add',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 10.0, fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                showSelectSecondaryConditionDialog(context, _conditionsPrimary, _conditionsSecondary, setState,
                                    (secondaryConditions) {
                                  _conditionsSecondary = secondaryConditions;
                                  List<String> conditionsEncoded = _conditionsSecondary.map((condition) => jsonEncode(condition.toJson())).toList();
                                  _prefs.secondaryConditions = [];
                                  _prefs.secondaryConditions = conditionsEncoded;

                                  Navigator.of(context).pop();
                                  setState(() {});
                                });
                              },
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return initProfileDataEmptyField(context, "Secondary Conditions", () {
        print(">SELECT CONDITIONS");
        showSelectSecondaryConditionDialog(context, _conditionsPrimary, _conditionsSecondary, setState, (secondaryConditions) async {
          _conditionsSecondary = secondaryConditions;

          List<String> conditionsEncoded = _conditionsSecondary.map((condition) => jsonEncode(condition.toJson())).toList();
          _prefs.secondaryConditions = conditionsEncoded;
          final updateData = {
            'patient_secondaryConditions': _conditionsSecondary,
          };
          await updateProfile(context, updateData);
          Navigator.of(context).pop();
          setState(() {});
        });
      });
    }
  }

  Widget _initAdditionalConditions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _conditionsAdditional = [];
    _prefs.additionalConditions.forEach((additional) {
      Map<String, dynamic> temp = jsonDecode(additional);
      Additional tempCondition = Additional.fromJson(temp);
      _conditionsAdditional.add(tempCondition);
    });
    if (_conditionsAdditional.length > 0) {
      return Align(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.025, vertical: size.width * 0.001),
          child: Column(
            children: [
              _initTitleField(context, "Additional Conditions"),
              SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 80.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: _conditionsAdditional.length,
                            itemBuilder: (BuildContext context, int index) {
                              final additional = _conditionsAdditional[index];
                              return Stack(
                                children: [
                                  Container(
                                    width: size.width * 0.3,
                                    padding: EdgeInsets.all(5.0),
                                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: size.width * 0.25,
                                          child: Center(
                                            child: Text(
                                              additional.title!,
                                              style: TextStyle(color: AppColor.content, fontSize: size.width * 0.03, fontWeight: FontWeight.w600),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  editMode
                                      ? Positioned(
                                          top: 5.0,
                                          left: (size.width * 0.3) - 10.0,
                                          child: InkWell(
                                            child: Container(
                                              height: 20.0,
                                              width: 20.0,
                                              decoration: BoxDecoration(
                                                color: AppColor.secondaryColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12.0,
                                              ),
                                            ),
                                            onTap: () {
                                              print("> Delete Condition");
                                              setState(() {
                                                _conditionsAdditional.removeWhere((e) => e.title == additional.title);

                                                List<String> conditionsEncoded =
                                                    _conditionsAdditional.map((additional) => jsonEncode(additional.toJson())).toList();

                                                _prefs.additionalConditions = conditionsEncoded;
                                              });
                                            },
                                          ),
                                        )
                                      : Container(),
                                ],
                              );
                            },
                          ),
                        ),
                        _conditionsAdditional.length > 2
                            ? Positioned(
                                right: 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      bottomLeft: Radius.circular(15.0),
                                    ),
                                  ),
                                  height: 80.0,
                                  width: size.width * 0.06,
                                  child: Center(
                                    child: Image(
                                      color: AppColor.background,
                                      width: 15.0,
                                      image: AssetImage('assets/img/icon_arrowButton.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  editMode
                      ? Container(
                          child: Card(
                            elevation: 1.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: editMode ? AppColor.fifthColor : Colors.black,
                                )),
                            child: InkWell(
                              child: SizedBox(
                                width: size.width * 0.12,
                                height: 90.0,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 2.5),
                                      Image(
                                        height: 25.0,
                                        width: 25.0,
                                        image: AssetImage('assets/img/icon_plusButton.png'),
                                        fit: BoxFit.contain,
                                        color: AppColor.thirdColor,
                                      ),
                                      SizedBox(height: 2.0),
                                      Container(
                                        height: 15.0,
                                        width: 37.5,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            'Add',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 10.0, fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                showSelectAdditionalConditionDialog(context, _conditionsAdditional, setState, (additionalConditions) {
                                  _conditionsAdditional = additionalConditions;
                                  List<String> additionalsEncoded =
                                      _conditionsAdditional.map((additional) => jsonEncode(additional.toJson())).toList();
                                  _prefs.additionalConditions = [];
                                  _prefs.additionalConditions = additionalsEncoded;

                                  Navigator.of(context).pop();
                                  setState(() {});
                                });
                              },
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return initProfileDataEmptyField(context, "Additional Condition", () {
        showSelectAdditionalConditionDialog(context, _conditionsAdditional, setState, (additionalConditions) async {
          _conditionsAdditional = additionalConditions;
          List<String> additionalsEncoded = _conditionsAdditional.map((additional) => jsonEncode(additional.toJson())).toList();
          _prefs.additionalConditions = [];
          _prefs.additionalConditions = additionalsEncoded;
          final updateData = {
            'patient_additionalConditions': _conditionsAdditional,
          };
          await updateProfile(context, updateData);
          Navigator.of(context).pop();
          setState(() {});
        });
      });
    }
  }

  ///////////
  //THERAPEUTICS PROFILE
  Widget _initTherapeuticsProfile(BuildContext context, UserPreference _prefs) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          _initAddTherapeutic(context),
          SizedBox(height: size.height * 0.01),
          _initTherapeuticsMethods(context),
          SizedBox(height: size.height * 0.01),
          _initComsuptionPreferencesMethods(context),
          SizedBox(height: size.height * 0.02),
          _initCigarette(context),
          SizedBox(height: size.height * 0.01),
          _initCannabis(context),
          SizedBox(height: size.height * 0.01),
          _initDrugs(context),
          SizedBox(height: size.height * 0.02),
          Divider(height: 5.0, color: AppColor.primaryColor),
        ],
      ),
    );
  }

  Widget _initAddTherapeutic(BuildContext context) {
    return initProfileDataEmptyField(context, "Add Therapeutic", () {
      showAlertMessageTwoAction(context, 200, 'Add Therapeutic', 'Which type of therapeutic would you like to add?', 'Cannabis', 'Other', () {
        Navigator.of(context).pop();
        Therapeutic cannabisTherapeutic = new Therapeutic(kind: 'cannabis');
        _showTherapeuticsDialog(context, cannabisTherapeutic, (therapeutic) async {
          List<Therapeutic> therapeuticsListTemp = [];

          _prefs.therapeutics.forEach((therapeutic) {
            Map<String, dynamic> temp = jsonDecode(therapeutic);
            Therapeutic tempTherapeutic = Therapeutic.fromJson(temp);
            therapeuticsListTemp.add(tempTherapeutic);
          });

          therapeuticsListTemp.add(therapeutic);

          List<String> therapeuticsEncoded = therapeuticsListTemp.map((therapeutic) => jsonEncode(therapeutic.toJson())).toList();
          _prefs.therapeutics = [];
          _prefs.therapeutics = therapeuticsEncoded;

          final updateData = {
            'patient_therapeutics': therapeuticsListTemp,
          };
          await updateProfile(context, updateData);
          Navigator.of(context).pop();
          setState(() {});
        });
      }, () {
        Navigator.of(context).pop();
        Therapeutic noncannabisTherapeutic = new Therapeutic(kind: 'noncannabis');
        _showTherapeuticsDialog(context, noncannabisTherapeutic, (therapeutic) async {
          List<Therapeutic> therapeuticsListTemp = [];

          _prefs.therapeutics.forEach((therapeutic) {
            Map<String, dynamic> temp = jsonDecode(therapeutic);
            Therapeutic tempTherapeutic = Therapeutic.fromJson(temp);
            therapeuticsListTemp.add(tempTherapeutic);
          });

          therapeuticsListTemp.add(therapeutic);

          List<String> therapeuticsEncoded = therapeuticsListTemp.map((therapeutic) => jsonEncode(therapeutic.toJson())).toList();
          _prefs.therapeutics = [];
          _prefs.therapeutics = therapeuticsEncoded;

          final updateData = {
            'patient_therapeutics': therapeuticsListTemp,
          };
          await updateProfile(context, updateData);
          Navigator.of(context).pop();
          setState(() {});
        });
      });
    });
  }

  Widget _initTherapeuticsMethods(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _therapeutics = [];
    _prefs.therapeutics.forEach((therapeutic) {
      Map<String, dynamic> temp = jsonDecode(therapeutic);
      Therapeutic tempTherapeutic = Therapeutic.fromJson(temp);
      _therapeutics.add(tempTherapeutic);
    });
    if (_therapeutics.length > 0) {
      return Align(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.025, vertical: size.width * 0.001),
          child: Column(
            children: [
              _initTitleField(context, "Therapeutics Methods"),
              SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 175.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: _therapeutics.length,
                        itemBuilder: (BuildContext context, int index) {
                          final therapeutic = _therapeutics[index];
                          return InkWell(
                            onTap: () {
                              _showCardTherapeutic(context, therapeutic);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: size.width * 0.3,
                                  padding: EdgeInsets.all(5.0),
                                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 2.5),
                                      Container(
                                        height: 21.0,
                                        width: size.width * 0.26,
                                        decoration: BoxDecoration(
                                          color: therapeutic.kind == "cannabis" ? AppColor.secondaryColor : AppColor.thirdColor,
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        child: Center(
                                            child: Text(
                                          therapeutic.kind == "cannabis" ? "Cannabis" : "Other",
                                          style: TextStyle(
                                              fontSize: AppFontSizes.contentSmallSize, color: AppColor.background, fontWeight: FontWeight.bold),
                                        )),
                                      ),
                                      SizedBox(height: 10.0),
                                      Image(
                                        color: AppColor.primaryColor,
                                        height: 35.0,
                                        width: 35.0,
                                        image: AssetImage('assets/img/medication/${AppData().iconMedication(therapeutic.method!)}'),
                                        fit: BoxFit.contain,
                                      ),
                                      Container(
                                        height: 20.0,
                                        width: 80.0,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            therapeutic.method!,
                                            style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize),
                                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Column(
                                        children: [
                                          Divider(height: 7.5, color: AppColor.secondaryColor),
                                          Text(
                                            therapeutic.productBrand!,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.contentSize - 1.0),
                                          ),
                                          SizedBox(height: 2.5),
                                          Text(
                                            therapeutic.kind == 'cannabis' ? therapeutic.parameters! : '',
                                            style: TextStyle(color: AppColor.thirdColor, fontSize: AppFontSizes.contentSmallSize - 1.5),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                editMode
                                    ? Positioned(
                                        top: 5.0,
                                        left: (size.width * 0.275) - 10.0,
                                        child: InkWell(
                                          child: Container(
                                            height: 20.0,
                                            width: 20.0,
                                            decoration: BoxDecoration(
                                              color: AppColor.secondaryColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 12.0,
                                            ),
                                          ),
                                          onTap: () {
                                            print("> Delete Therapeutic");
                                            setState(() {
                                              _therapeutics.removeWhere((e) => e == therapeutic);

                                              List<String> _therapeuticsEncoded =
                                                  _therapeutics.map((therapeutic) => jsonEncode(therapeutic.toJson())).toList();

                                              _prefs.therapeutics = _therapeuticsEncoded;
                                            });
                                          },
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _initComsuptionPreferencesMethods(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _medications = [];
    _prefs.medications.forEach((medication) {
      Map<String, dynamic> temp = jsonDecode(medication);
      Medication tempMedication = Medication.fromJson(temp);
      _medications.add(tempMedication);
    });
    if (_medications.length > 0) {
      return Align(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.025, vertical: size.width * 0.001),
          child: Column(
            children: [
              _initTitleField(context, "Consumption Preferences"),
              SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 150.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: _medications.length,
                            itemBuilder: (BuildContext context, int index) {
                              final medication = _medications[index];
                              return Stack(
                                children: [
                                  Container(
                                    width: size.width * 0.23,
                                    padding: EdgeInsets.all(5.0),
                                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Image(
                                        color: AppColor.primaryColor,
                                        height: 50.0,
                                        width: 50.0,
                                        image: AssetImage('assets/img/medication/${AppData().iconMedication(medication.title!)}'),
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                        height: 20.0,
                                        width: 80.0,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            medication.title!,
                                            style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize),
                                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Column(
                                        children: [
                                          Divider(height: 7.5, color: AppColor.primaryColor),
                                          Text(
                                            medication.preference,
                                            style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.contentSmallSize),
                                          ),
                                          SizedBox(height: 2.5),
                                          Text(
                                            medication.experience,
                                            style: TextStyle(color: AppColor.thirdColor, fontSize: AppFontSizes.contentSmallSize - 1.8),
                                          ),
                                        ],
                                      ),
                                    ]),
                                  ),
                                  editMode
                                      ? Positioned(
                                          top: 5.0,
                                          left: (size.width * 0.23) - 10.0,
                                          child: InkWell(
                                            child: Container(
                                              height: 20.0,
                                              width: 20.0,
                                              decoration: BoxDecoration(
                                                color: AppColor.secondaryColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12.0,
                                              ),
                                            ),
                                            onTap: () {
                                              print("> Delete Medication");
                                              setState(() {
                                                _medications.removeWhere((e) => e.title == medication.title);

                                                List<String> _medicationsEncoded =
                                                    _medications.map((medication) => jsonEncode(medication.toJson())).toList();

                                                _prefs.medications = _medicationsEncoded;
                                              });
                                            },
                                          ),
                                        )
                                      : Container(),
                                ],
                              );
                            },
                          ),
                        ),
                        _medications.length > 3
                            ? Positioned(
                                right: 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25.0),
                                      bottomLeft: Radius.circular(25.0),
                                    ),
                                  ),
                                  height: 120.0,
                                  width: size.width * 0.06,
                                  child: Center(
                                    child: Image(
                                      color: AppColor.background,
                                      width: 15.0,
                                      image: AssetImage('assets/img/icon_arrowButton.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  editMode
                      ? Container(
                          child: Card(
                            elevation: 1.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: InkWell(
                              child: SizedBox(
                                width: size.width * 0.12,
                                height: 130.0,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 2.5),
                                      Image(
                                        height: 25.0,
                                        width: 25.0,
                                        image: AssetImage('assets/img/icon_plusButton.png'),
                                        fit: BoxFit.contain,
                                        color: AppColor.thirdColor,
                                      ),
                                      SizedBox(height: 2.0),
                                      Container(
                                        height: 15.0,
                                        width: 37.5,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            'Add',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 10.0, fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                _showComsuptionMethodsDialog(context, () {
                                  print(">UPDATE CONSUMPTION METHODS");
                                  setState(() {
                                    _medications = [];
                                    dataMedications.forEach((medication) {
                                      if (medication.isSelected) {
                                        _medications.add(medication);
                                      }
                                    });

                                    if (_medications.length > 0) {
                                      List<String> medicationEncoded = _medications.map((medication) => jsonEncode(medication.toJson())).toList();

                                      _prefs.medications = medicationEncoded;
                                      Navigator.of(context).pop();
                                    }
                                  });
                                });
                              },
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return initProfileDataEmptyField(context, "Consumption Preference", () {
        _showComsuptionMethodsDialog(context, () async {
          print(">>>Consumption Methods");

          _medications = [];

          dataMedications.forEach((medication) {
            if (medication.isSelected) {
              _medications.add(medication);
            }
          });

          if (_medications.length > 0) {
            List<String> medicationEncoded = _medications.map((medication) => jsonEncode(medication.toJson())).toList();
            _prefs.medications = medicationEncoded;
            final updateData = {
              'patient_medications': _medications,
            };
            await updateProfile(context, updateData);
            Navigator.of(context).pop();
            setState(() {});
          }
        });
      });
    }
  }

  void _showTherapeuticsDialog(BuildContext context, Therapeutic therapeutic, Function(Therapeutic) callback) {
    final size = MediaQuery.of(context).size;
    dataMedicationTherapeutics.forEach((dataMedicationsTherapeutic) {
      dataMedicationsTherapeutic.isSelected = false;
    });
    dataMedicationTherapeuticsNonCannabis.forEach((dataMedicationsTherapeutic) {
      dataMedicationsTherapeutic.isSelected = false;
    });
    _selectParameterFirst = false;
    _selectParameterSecond = false;
    _selectParameterThird = false;
    final _brandController = new TextEditingController();
    final _productController = new TextEditingController();
    final _dosageController = new TextEditingController();
    _clearTherapeuticsDialog();
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: therapeutic.kind == 'cannabis'
                        ? 550.0 + MediaQuery.of(context).viewInsets.bottom / 3
                        : 450.0 + MediaQuery.of(context).viewInsets.bottom / 3,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      print("::Cancel");
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    if (_validateTherapeutic(therapeutic)) {
                                      callback(therapeutic);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding:
                                EdgeInsets.only(right: size.width * 0.1, left: size.width * 0.1, top: MediaQuery.of(context).viewInsets.bottom / 4),
                            child: therapeutic.kind == 'cannabis'
                                ? SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              "Select your type product",
                                              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                            )),
                                        Container(
                                          height: 120.0,
                                          width: size.width * 0.8,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount: dataMedicationTherapeutics.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final medication = dataMedicationTherapeutics[index];
                                              return InkWell(
                                                child: Container(
                                                  width: size.width * 0.28,
                                                  padding: EdgeInsets.all(5.0),
                                                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.5),
                                                  decoration: BoxDecoration(
                                                      color: medication.isSelected ? AppColor.secondaryColor : Colors.white,
                                                      borderRadius: BorderRadius.circular(15.0),
                                                      border:
                                                          Border.all(color: medication.isSelected ? AppColor.secondaryColor : AppColor.primaryColor)),
                                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                    Image(
                                                      color: medication.isSelected ? AppColor.background : AppColor.primaryColor,
                                                      height: 50.0,
                                                      width: 50.0,
                                                      image: AssetImage('assets/img/medication/${medication.icon}'),
                                                      fit: BoxFit.contain,
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Text(
                                                      medication.title!,
                                                      style: TextStyle(
                                                          color: medication.isSelected ? AppColor.background : AppColor.primaryColor,
                                                          fontSize: AppFontSizes.contentSize - 1.0),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ]),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    if (medication.isSelected) {
                                                      medication.isSelected = false;
                                                      therapeutic.method = "";
                                                    } else {
                                                      dataMedicationTherapeutics.forEach((m) {
                                                        m.isSelected = false;
                                                      });
                                                      medication.isSelected = true;
                                                      therapeutic.method = medication.title;
                                                    }
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              "Select your cannabis parameters",
                                              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                            )),
                                        SizedBox(height: 5.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              child: Container(
                                                width: 90.0,
                                                height: 60.0,
                                                padding: EdgeInsets.all(5.0),
                                                margin: EdgeInsets.all(2.5),
                                                decoration: BoxDecoration(
                                                    color: _selectParameterFirst ? AppColor.secondaryColor : Colors.white,
                                                    borderRadius: BorderRadius.circular(15.0),
                                                    border:
                                                        Border.all(color: _selectParameterFirst ? AppColor.secondaryColor : AppColor.primaryColor)),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 35.0,
                                                          child: Text(
                                                            "CBD",
                                                            style: TextStyle(
                                                                color: _selectParameterFirst ? AppColor.background : AppColor.content,
                                                                fontSize: AppFontSizes.contentSize,
                                                                fontWeight: FontWeight.w700),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                child: Icon(
                                                                  Icons.arrow_upward,
                                                                  color: _selectParameterFirst ? AppColor.background : AppColor.secondaryColor,
                                                                  size: 18.0,
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  "High",
                                                                  style: TextStyle(
                                                                      color: _selectParameterFirst ? AppColor.background : AppColor.content,
                                                                      fontSize: AppFontSizes.contentSmallSize - 1.0),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 35.0,
                                                          child: Text(
                                                            "THC",
                                                            style: TextStyle(
                                                                color: _selectParameterFirst ? AppColor.background : AppColor.content,
                                                                fontSize: AppFontSizes.contentSize,
                                                                fontWeight: FontWeight.w700),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                child: Icon(
                                                                  Icons.arrow_downward,
                                                                  color: _selectParameterFirst ? AppColor.background : AppColor.thirdColor,
                                                                  size: 18.0,
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  "Low",
                                                                  style: TextStyle(
                                                                      color: _selectParameterFirst ? AppColor.background : AppColor.content,
                                                                      fontSize: AppFontSizes.contentSmallSize - 1.0),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (_selectParameterFirst) {
                                                    _selectParameterFirst = false;
                                                    therapeutic.parameters = "";
                                                  } else {
                                                    _selectParameterFirst = true;
                                                    _selectParameterSecond = false;
                                                    _selectParameterThird = false;
                                                    therapeutic.parameters = "High CBD / Low THC";
                                                  }
                                                });
                                              },
                                            ),
                                            InkWell(
                                              child: Container(
                                                width: 105.0,
                                                height: 60.0,
                                                padding: EdgeInsets.all(5.0),
                                                margin: EdgeInsets.all(2.5),
                                                decoration: BoxDecoration(
                                                    color: _selectParameterSecond ? AppColor.secondaryColor : Colors.white,
                                                    borderRadius: BorderRadius.circular(15.0),
                                                    border:
                                                        Border.all(color: _selectParameterSecond ? AppColor.secondaryColor : AppColor.primaryColor)),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 35.0,
                                                                child: Text(
                                                                  "CBD",
                                                                  style: TextStyle(
                                                                      color: _selectParameterSecond ? AppColor.background : AppColor.content,
                                                                      fontSize: AppFontSizes.contentSize,
                                                                      fontWeight: FontWeight.w700),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      child: Icon(
                                                                        Icons.horizontal_rule,
                                                                        color: AppColor.fifthColor,
                                                                        size: 18.0,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child: Text(
                                                                        "Balanced",
                                                                        style: TextStyle(
                                                                            color: _selectParameterSecond ? AppColor.background : AppColor.content,
                                                                            fontSize: AppFontSizes.contentSmallSize - 2.5),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 35.0,
                                                                child: Text(
                                                                  "THC",
                                                                  style: TextStyle(
                                                                      color: _selectParameterSecond ? AppColor.background : AppColor.content,
                                                                      fontSize: AppFontSizes.contentSize,
                                                                      fontWeight: FontWeight.w700),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      child: Icon(
                                                                        Icons.horizontal_rule,
                                                                        color: AppColor.fifthColor,
                                                                        size: 18.0,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child: Text(
                                                                        "Balanced",
                                                                        style: TextStyle(
                                                                            color: _selectParameterSecond ? AppColor.background : AppColor.content,
                                                                            fontSize: AppFontSizes.contentSmallSize - 2.5),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (_selectParameterSecond) {
                                                    _selectParameterSecond = false;
                                                    therapeutic.parameters = "";
                                                  } else {
                                                    _selectParameterFirst = false;
                                                    _selectParameterSecond = true;
                                                    _selectParameterThird = false;
                                                    therapeutic.parameters = "Balanced CBD / THC";
                                                  }
                                                });
                                              },
                                            ),
                                            InkWell(
                                              child: Container(
                                                width: 90.0,
                                                height: 60.0,
                                                padding: EdgeInsets.all(5.0),
                                                margin: EdgeInsets.all(2.5),
                                                decoration: BoxDecoration(
                                                    color: _selectParameterThird ? AppColor.secondaryColor : Colors.white,
                                                    borderRadius: BorderRadius.circular(15.0),
                                                    border:
                                                        Border.all(color: _selectParameterThird ? AppColor.secondaryColor : AppColor.primaryColor)),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 35.0,
                                                          child: Text(
                                                            "CBD",
                                                            style: TextStyle(
                                                                color: _selectParameterThird ? AppColor.background : AppColor.content,
                                                                fontSize: AppFontSizes.contentSize,
                                                                fontWeight: FontWeight.w700),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                child: Icon(
                                                                  Icons.arrow_downward,
                                                                  color: _selectParameterThird ? AppColor.background : AppColor.thirdColor,
                                                                  size: 18.0,
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  "Low",
                                                                  style: TextStyle(
                                                                      color: _selectParameterThird ? AppColor.background : AppColor.content,
                                                                      fontSize: AppFontSizes.contentSmallSize - 1.0),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 35.0,
                                                          child: Text(
                                                            "THC",
                                                            style: TextStyle(
                                                                color: _selectParameterThird ? AppColor.background : AppColor.content,
                                                                fontSize: AppFontSizes.contentSize,
                                                                fontWeight: FontWeight.w700),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                child: Icon(
                                                                  Icons.arrow_upward,
                                                                  color: _selectParameterThird ? AppColor.background : AppColor.secondaryColor,
                                                                  size: 18.0,
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  "High",
                                                                  style: TextStyle(
                                                                      color: _selectParameterThird ? AppColor.background : AppColor.content,
                                                                      fontSize: AppFontSizes.contentSmallSize - 1.0),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (_selectParameterThird) {
                                                    _selectParameterThird = false;
                                                    therapeutic.parameters = "";
                                                  } else {
                                                    _selectParameterFirst = false;
                                                    _selectParameterSecond = false;
                                                    _selectParameterThird = true;
                                                    therapeutic.parameters = "Low CBD / High THC";
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Material(
                                          elevation: 2.5,
                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                          child: TextField(
                                            autofocus: false,
                                            controller: _brandController,
                                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                            keyboardType: TextInputType.text,
                                            textCapitalization: TextCapitalization.sentences,
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: "Enter your brand of product",
                                                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                errorText: null, //"\u26A0 email incorrecto",
                                                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius: BorderRadius.circular(size.width * 0.025),
                                                ),
                                                border: OutlineInputBorder(
                                                    borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                    borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                errorStyle: TextStyle(fontSize: 11.0)),
                                            onChanged: (value) {
                                              therapeutic.productBrand = value;
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Material(
                                          elevation: 2.5,
                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                          child: TextField(
                                            autofocus: false,
                                            controller: _productController,
                                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                            keyboardType: TextInputType.text,
                                            textCapitalization: TextCapitalization.sentences,
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: "Enter your product name",
                                                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                errorText: null, //"\u26A0 email incorrecto",
                                                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius: BorderRadius.circular(size.width * 0.025),
                                                ),
                                                border: OutlineInputBorder(
                                                    borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                    borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                errorStyle: TextStyle(fontSize: 11.0)),
                                            onChanged: (value) {
                                              therapeutic.productName = value;
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width * 0.35,
                                              child: Material(
                                                elevation: 2.5,
                                                borderRadius: BorderRadius.circular(size.width * 0.025),
                                                child: TextField(
                                                  autofocus: false,
                                                  controller: _dosageController,
                                                  style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                  keyboardType: TextInputType.text,
                                                  textCapitalization: TextCapitalization.sentences,
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      hintText: "Dosage",
                                                      hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                      errorText: null, //"\u26A0 email incorrecto",
                                                      contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                      enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide.none,
                                                        borderRadius: BorderRadius.circular(size.width * 0.025),
                                                      ),
                                                      border: OutlineInputBorder(
                                                          borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                          borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                      errorStyle: TextStyle(fontSize: 11.0)),
                                                  onChanged: (value) {
                                                    therapeutic.productDosage = value;
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5.0),
                                            Container(
                                              height: 45.0,
                                              width: size.width * 0.435,
                                              alignment: Alignment.centerRight,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: _dataMeasurement.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  final measurement = _dataMeasurement[index];
                                                  return InkWell(
                                                    child: Container(
                                                      width: size.width * 0.195,
                                                      decoration: BoxDecoration(
                                                        color: measurement.isSelected ? AppColor.secondaryColor : AppColor.background,
                                                        borderRadius: _initBorderMeasurement(index),
                                                        border: Border.all(
                                                            color: measurement.isSelected ? AppColor.secondaryColor : AppColor.primaryColor),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          measurement.title!,
                                                          style: TextStyle(
                                                              color: measurement.isSelected ? Colors.white : AppColor.primaryColor,
                                                              fontSize: AppFontSizes.contentSize - 1.0,
                                                              fontWeight: FontWeight.w700),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        if (measurement.isSelected) {
                                                          measurement.isSelected = false;
                                                          therapeutic.productMeasurement = "";
                                                        } else {
                                                          _dataMeasurement.forEach((m) {
                                                            m.isSelected = false;
                                                          });
                                                          measurement.isSelected = true;
                                                          therapeutic.productMeasurement = measurement.title;
                                                        }
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              "Select your type product",
                                              style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                            )),
                                        Container(
                                          height: 120.0,
                                          width: size.width * 0.8,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount: dataMedicationTherapeuticsNonCannabis.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final medication = dataMedicationTherapeuticsNonCannabis[index];
                                              return InkWell(
                                                child: Container(
                                                  width: size.width * 0.28,
                                                  margin: EdgeInsets.only(top: 10.0, right: 2.5, bottom: 5.0),
                                                  decoration: BoxDecoration(
                                                      color: medication.isSelected ? AppColor.secondaryColor : Colors.white,
                                                      borderRadius: BorderRadius.circular(15.0),
                                                      border:
                                                          Border.all(color: medication.isSelected ? AppColor.secondaryColor : AppColor.primaryColor)),
                                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                    Image(
                                                      color: medication.isSelected ? AppColor.background : AppColor.primaryColor,
                                                      height: 50.0,
                                                      width: 50.0,
                                                      image: AssetImage('assets/img/medication/${medication.icon}'),
                                                      fit: BoxFit.contain,
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Text(
                                                      medication.title!,
                                                      style: TextStyle(
                                                          color: medication.isSelected ? AppColor.background : AppColor.primaryColor,
                                                          fontSize: AppFontSizes.contentSize - 1.0),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ]),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    if (medication.isSelected) {
                                                      medication.isSelected = false;
                                                      therapeutic.method = "";
                                                    } else {
                                                      dataMedicationTherapeuticsNonCannabis.forEach((m) {
                                                        m.isSelected = false;
                                                      });
                                                      medication.isSelected = true;
                                                      therapeutic.method = medication.title;
                                                    }
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Material(
                                          elevation: 2.5,
                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                          child: TextField(
                                            autofocus: false,
                                            controller: _brandController,
                                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                            keyboardType: TextInputType.text,
                                            textCapitalization: TextCapitalization.sentences,
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: "Enter your brand of product",
                                                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                errorText: null, //"\u26A0 email incorrecto",
                                                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius: BorderRadius.circular(size.width * 0.025),
                                                ),
                                                border: OutlineInputBorder(
                                                    borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                    borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                errorStyle: TextStyle(fontSize: 11.0)),
                                            onChanged: (value) {
                                              therapeutic.productBrand = value;
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Material(
                                          elevation: 2.5,
                                          borderRadius: BorderRadius.circular(size.width * 0.025),
                                          child: TextField(
                                            autofocus: false,
                                            controller: _productController,
                                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                            keyboardType: TextInputType.text,
                                            textCapitalization: TextCapitalization.sentences,
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: "Enter your product name",
                                                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                errorText: null, //"\u26A0 email incorrecto",
                                                contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius: BorderRadius.circular(size.width * 0.025),
                                                ),
                                                border: OutlineInputBorder(
                                                    borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                    borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                errorStyle: TextStyle(fontSize: 11.0)),
                                            onChanged: (value) {
                                              therapeutic.productName = value;
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width * 0.35,
                                              child: Material(
                                                elevation: 2.5,
                                                borderRadius: BorderRadius.circular(size.width * 0.025),
                                                child: TextField(
                                                  autofocus: false,
                                                  controller: _dosageController,
                                                  style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                  keyboardType: TextInputType.text,
                                                  textCapitalization: TextCapitalization.sentences,
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      hintText: "Dosage",
                                                      hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                      errorText: null, //"\u26A0 email incorrecto",
                                                      contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                                      enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide.none,
                                                        borderRadius: BorderRadius.circular(size.width * 0.025),
                                                      ),
                                                      border: OutlineInputBorder(
                                                          borderRadius: new BorderRadius.circular(size.width * 0.025),
                                                          borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                      errorStyle: TextStyle(fontSize: 11.0)),
                                                  onChanged: (value) {
                                                    therapeutic.productDosage = value;
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5.0),
                                            Container(
                                              height: 45.0,
                                              width: size.width * 0.435,
                                              alignment: Alignment.centerRight,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: _dataMeasurement.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  final measurement = _dataMeasurement[index];
                                                  return InkWell(
                                                    child: Container(
                                                      width: size.width * 0.195,
                                                      decoration: BoxDecoration(
                                                        color: measurement.isSelected ? AppColor.secondaryColor : AppColor.background,
                                                        borderRadius: _initBorderMeasurement(index),
                                                        border: Border.all(
                                                            color: measurement.isSelected ? AppColor.secondaryColor : AppColor.primaryColor),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          measurement.title!,
                                                          style: TextStyle(
                                                              color: measurement.isSelected ? Colors.white : AppColor.primaryColor,
                                                              fontSize: AppFontSizes.contentSize - 1.0,
                                                              fontWeight: FontWeight.w700),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        if (measurement.isSelected) {
                                                          measurement.isSelected = false;
                                                          therapeutic.productMeasurement = "";
                                                        } else {
                                                          _dataMeasurement.forEach((m) {
                                                            m.isSelected = false;
                                                          });
                                                          measurement.isSelected = true;
                                                          therapeutic.productMeasurement = measurement.title;
                                                        }
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  bool _validateTherapeutic(Therapeutic therapeutic) {
    if (therapeutic.method == null || therapeutic.method!.isEmpty) {
      showAlertMessage(context, 'Please select your type product', () {
        Navigator.pop(context);
      });
      return false;
    }
    if (therapeutic.kind == 'cannabis') {
      if (therapeutic.parameters == null || therapeutic.parameters!.isEmpty) {
        showAlertMessage(context, 'Please select your cannabis parameters', () {
          Navigator.pop(context);
        });
        return false;
      }
    }
    if (therapeutic.productBrand == null || therapeutic.productBrand!.isEmpty) {
      showAlertMessage(context, 'Please enter your brand of product', () {
        Navigator.pop(context);
      });
      return false;
    }
    if (therapeutic.productDosage == null || therapeutic.productDosage!.isEmpty) {
      therapeutic.productMeasurement = null;
    } else {
      if (therapeutic.productMeasurement == null || therapeutic.productMeasurement!.isEmpty) {
        showAlertMessage(context, 'Please select your dosage measurement of product', () {
          Navigator.pop(context);
        });
        return false;
      }
    }

    return true;
  }

  BorderRadiusGeometry _initBorderMeasurement(int index) {
    final size = MediaQuery.of(context).size;
    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(size.width * 0.025),
        bottomLeft: Radius.circular(size.width * 0.025),
      );
    } else if (_dataMeasurement.length - 1 == index) {
      return BorderRadius.only(
        topRight: Radius.circular(size.width * 0.025),
        bottomRight: Radius.circular(size.width * 0.025),
      );
    } else {
      return BorderRadius.circular(0.0);
    }
  }

  void _clearTherapeuticsDialog() {
    _dataMeasurement.forEach((e) {
      e.isSelected = false;
    });
  }

  void _showCardTherapeutic(BuildContext context, Therapeutic therapeutic) {
    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      pageBuilder: (_, __, ___) {
        return Dialog(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.1),
          ),
          child: Stack(
            children: [
              Container(
                height: therapeutic.kind == 'cannabis' ? size.height * 0.47 : size.height * 0.4,
                margin: EdgeInsets.all(1.5),
                decoration: BoxDecoration(gradient: AppColor.primaryGradient, borderRadius: BorderRadius.circular(size.width * 0.1)),
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "Consumption Method",
                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  height: size.height * 0.05,
                                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: AppColor.thirdColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: size.height * 0.035),
                                      Image(
                                        color: Colors.white,
                                        image: AssetImage('assets/img/medication/${AppData().iconMedication(therapeutic.method!)}'),
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: size.height * 0.01),
                                      Container(
                                        width: size.width * 0.35,
                                        child: Center(
                                          child: Text(
                                            therapeutic.method!,
                                            style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 5.0,
                              child: Image(
                                color: AppColor.fifthColor,
                                width: 15.0,
                                image: AssetImage('assets/img/icon_arrow.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        therapeutic.kind == 'cannabis'
                            ? Stack(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        child: Text(
                                          "Cannabis Parameters",
                                          style:
                                              TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Container(
                                        height: size.height * 0.05,
                                        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          color: AppColor.thirdColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(18.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            therapeutic.parameters!,
                                            style:
                                                TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize + 1.0, fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 5.0,
                                    child: Image(
                                      color: AppColor.fifthColor,
                                      width: 15.0,
                                      image: AssetImage('assets/img/icon_arrow.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "Brand of Product",
                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  height: size.height * 0.05,
                                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: AppColor.thirdColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      therapeutic.productBrand!,
                                      style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize + 1.0, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 5.0,
                              child: Image(
                                color: AppColor.fifthColor,
                                width: 15.0,
                                image: AssetImage('assets/img/icon_arrow.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "Product Name",
                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  height: size.height * 0.05,
                                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: AppColor.thirdColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      therapeutic.productName!.isEmpty || therapeutic.productName == 'null' ? '-' : therapeutic.productName!,
                                      style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize + 1.0, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 5.0,
                              child: Image(
                                color: AppColor.fifthColor,
                                width: 15.0,
                                image: AssetImage('assets/img/icon_arrow.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "Dosage",
                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  height: size.height * 0.05,
                                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: AppColor.thirdColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      therapeutic.productDosage!.isEmpty || therapeutic.productDosage == 'null'
                                          ? '-'
                                          : therapeutic.productDosage! + " " + therapeutic.productMeasurement!,
                                      style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize + 1.0, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 5.0,
                              child: Image(
                                color: AppColor.fifthColor,
                                width: 15.0,
                                image: AssetImage('assets/img/icon_arrow.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: InkWell(
                  child: Container(
                    height: 35.0,
                    width: 35.0,
                    decoration: BoxDecoration(
                      color: AppColor.background,
                      borderRadius: BorderRadius.circular(17.5),
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColor.thirdColor,
                      size: 25.0,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  //Cigarette
  Widget _initCigarette(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_prefs.cigarettesResponse) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: editMode ? Border.all(color: AppColor.fifthColor) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 25.0,
                            height: 25.0,
                            padding: EdgeInsets.only(left: size.width * 0.015, top: size.height * 0.004, bottom: size.height * 0.004),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                              child: Icon(
                                Icons.smoking_rooms,
                                color: Colors.white,
                                size: 15.0,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            "Cigarette",
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: AppFontSizes.contentSmallSize,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.005),
                    _prefs.cigarettesConsume
                        ? Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              " •  " + "Consume " + _prefs.cigarettesAmount.toString() + " per day",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 15.0, bottom: 5.0),
                            child: Text(
                              " •  Doesn't Consume",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.01),
            editMode
                ? InkWell(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 20.0,
                        width: 20.0,
                        margin: EdgeInsets.only(top: 2.5, right: 2.5),
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 12.0,
                        ),
                      ),
                    ),
                    onTap: () {
                      _showCigaretteDialog(context, (
                        consume,
                        amount,
                      ) async {
                        _prefs.cigarettesConsume = consume;
                        _prefs.cigarettesAmount = amount;
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      });
                    },
                  )
                : Container(),
          ],
        ),
      );
    } else {
      return Align(
        child: InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: size.width * 0.85,
              height: 60.0,
              decoration: BoxDecoration(
                gradient: AppColor.secondaryGradient,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20.0,
                    left: size.width * 0.035,
                    child: Text(
                      'Do you smoke cigarettes?',
                      style: TextStyle(
                        color: AppColor.background,
                        fontSize: AppFontSizes.buttonSize + 3.0,
                      ),
                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                    ),
                  ),
                  Positioned(
                    top: 3.0,
                    left: size.width * 0.025,
                    child: Text(
                      'Do you smoke cigarettes?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.1),
                        fontWeight: FontWeight.w900,
                        fontSize: AppFontSizes.buttonSize + 15.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            _showCigaretteDialog(context, (
              consume,
              amount,
            ) async {
              setState(() async {
                final updateData = {
                  'patient_cigarettes': {
                    'cigarette_consume': consume,
                    'cigarette_amountPerDay': amount,
                  },
                };
                await updateProfile(context, updateData);
                Navigator.of(context).pop();
              });
            });
          },
        ),
      );
    }
  }

  void _showCigaretteDialog(BuildContext context, Function(bool consume, int amount) callback) {
    final size = MediaQuery.of(context).size;
    bool _selectedYes = false;
    bool _selectedNo = false;
    int _amountValue = 0;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 360,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      print("::Cancel");
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    if (_selectedYes && _amountValue > 0) {
                                      callback(_selectedYes, _amountValue);
                                    } else if (_selectedNo) {
                                      callback(false, 0);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 220.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Do you smoke cigarette?",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Card(
                                      elevation: 2.5,
                                      color: _selectedYes ? AppColor.secondaryColor : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: InkWell(
                                          child: SizedBox(
                                            width: size.width * 0.35,
                                            height: 50.0,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                  color: _selectedYes ? Colors.white : AppColor.primaryColor,
                                                  fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                                                ),
                                                textAlign: TextAlign.center,
                                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            if (_selectedYes) {
                                              _selectedYes = false;
                                            } else {
                                              _selectedYes = true;
                                              _selectedNo = false;
                                            }
                                            setState(() {});
                                          }),
                                    ),
                                    SizedBox(width: 10.0),
                                    Card(
                                      elevation: 2.5,
                                      color: _selectedNo ? AppColor.secondaryColor : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: InkWell(
                                          child: SizedBox(
                                            width: size.width * 0.35,
                                            height: 50.0,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                  color: _selectedNo ? Colors.white : AppColor.primaryColor,
                                                  fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                                                ),
                                                textAlign: TextAlign.center,
                                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            if (_selectedNo) {
                                              _selectedNo = false;
                                            } else {
                                              _selectedNo = true;
                                              _selectedYes = false;
                                            }
                                            setState(() {});
                                          }),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15.0),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "How many cigarettes do you smoke per day?",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 15.0),
                                NumberPicker(
                                  value: _amountValue,
                                  minValue: 0,
                                  maxValue: 30,
                                  step: 1,
                                  itemHeight: 50,
                                  axis: Axis.horizontal,
                                  onChanged: (value) => setState(() => _amountValue = value),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: _selectedYes ? AppColor.secondaryColor : AppColor.content.withOpacity(0.5)),
                                  ),
                                  selectedTextStyle: TextStyle(
                                      fontSize: AppFontSizes.titleSize - 2.0,
                                      color: _selectedYes ? AppColor.secondaryColor : AppColor.content.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  //Cannabis
  Widget _initCannabis(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_prefs.cannabisResponse) {
      List<String> _cannabisList = [];
      _prefs.cannabisKind.forEach((kind) {
        _cannabisList.add(kind);
      });
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: editMode ? Border.all(color: AppColor.fifthColor) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 25.0,
                            height: 25.0,
                            padding: EdgeInsets.only(left: size.width * 0.015, top: size.height * 0.004, bottom: size.height * 0.004),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                              child: Icon(
                                Icons.smoking_rooms,
                                color: Colors.white,
                                size: 15.0,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            "Cannabis",
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: AppFontSizes.contentSmallSize,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ],
                      ),
                    ),
                    _prefs.cannabisConsume
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _cannabisList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final kindSelected = _cannabisList[index];
                                    return Container(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        " •  " + kindSelected,
                                        style: TextStyle(
                                          color: AppColor.content,
                                          fontSize: AppFontSizes.contentSize,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: size.width * 0.01),
                              Padding(
                                padding: EdgeInsets.only(left: 15.0),
                                child: Divider(height: 5.0, color: AppColor.primaryColor),
                              ),
                              SizedBox(height: size.width * 0.01),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                child: Text(
                                  " •  " + _prefs.cannabisFrequency,
                                  style: TextStyle(
                                    color: AppColor.content,
                                    fontSize: AppFontSizes.contentSize,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 15.0, bottom: 5.0),
                            child: Text(
                              " •  Doesn't Consume",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.01),
            editMode
                ? InkWell(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 20.0,
                        width: 20.0,
                        margin: EdgeInsets.only(top: 2.5, right: 2.5),
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 12.0,
                        ),
                      ),
                    ),
                    onTap: () {
                      _showCannabisDialog(context, (
                        consume,
                        kind,
                        frequecy,
                      ) async {
                        _prefs.cannabisConsume = consume;
                        _prefs.cannabisKind = kind;
                        _prefs.cannabisFrequency = frequecy;
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      });
                    },
                  )
                : Container(),
          ],
        ),
      );
    } else {
      return Align(
        child: InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: size.width * 0.85,
              height: 60.0,
              decoration: BoxDecoration(
                gradient: AppColor.secondaryGradient,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20.0,
                    left: size.width * 0.035,
                    child: Text(
                      'Do you currently use cannabis?',
                      style: TextStyle(
                        color: AppColor.background,
                        fontSize: AppFontSizes.buttonSize + 3.0,
                      ),
                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                    ),
                  ),
                  Positioned(
                    top: 3.0,
                    left: size.width * 0.025,
                    child: Text(
                      'Do you currently use cannabis?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.1),
                        fontWeight: FontWeight.w900,
                        fontSize: AppFontSizes.buttonSize + 15.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            _showCannabisDialog(context, (
              consume,
              kind,
              frequecy,
            ) async {
              setState(() async {
                final updateData = {
                  'patient_cannabis': {
                    'cannabis_consume': consume,
                    'cannabis_kindOfUse': kind,
                    'cannabis_frequencyOfUse': frequecy,
                  },
                };
                await updateProfile(context, updateData);
                Navigator.of(context).pop();
              });
            });
          },
        ),
      );
    }
  }

  void _showCannabisDialog(BuildContext context, Function(bool consume, List<String> kindList, String frequency) callback) {
    final size = MediaQuery.of(context).size;
    bool _selectedYes = false;
    bool _selectedNo = false;
    bool _kindSelfMedical = false;
    bool _kindPrescribed = false;
    bool _kindRecreational = false;
    List<String> _kindList = [];
    bool _frequencyDaily = false;
    bool _frequencyTimes = false;
    bool _frequencyWeek = false;
    bool _frequencyFortnight = false;
    bool _frequencyMonth = false;
    String _frequency = '';
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 630,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    if (_selectedYes) {
                                      callback(_selectedYes, _kindList.length > 0 ? _kindList : [], _frequency.isNotEmpty ? _frequency : '');
                                    } else if (_selectedNo) {
                                      callback(false, [], '');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 480.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Do you currently use cannabis?",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Card(
                                      elevation: 2.5,
                                      color: _selectedYes ? AppColor.secondaryColor : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: InkWell(
                                          child: SizedBox(
                                            width: size.width * 0.35,
                                            height: 50.0,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                  color: _selectedYes ? Colors.white : AppColor.primaryColor,
                                                  fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                                                ),
                                                textAlign: TextAlign.center,
                                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            if (_selectedYes) {
                                              _selectedYes = false;
                                            } else {
                                              _selectedYes = true;
                                              _selectedNo = false;
                                            }
                                            setState(() {});
                                          }),
                                    ),
                                    SizedBox(width: 10.0),
                                    Card(
                                      elevation: 2.5,
                                      color: _selectedNo ? AppColor.secondaryColor : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: InkWell(
                                          child: SizedBox(
                                            width: size.width * 0.35,
                                            height: 50.0,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                  color: _selectedNo ? Colors.white : AppColor.primaryColor,
                                                  fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                                                ),
                                                textAlign: TextAlign.center,
                                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            if (_selectedNo) {
                                              _selectedNo = false;
                                            } else {
                                              _selectedNo = true;
                                              _selectedYes = false;
                                              _kindList = [];
                                              _kindSelfMedical = false;
                                              _kindPrescribed = false;
                                              _kindRecreational = false;
                                              _frequency = '';
                                              _frequencyDaily = false;
                                              _frequencyTimes = false;
                                              _frequencyWeek = false;
                                              _frequencyFortnight = false;
                                              _frequencyMonth = false;
                                            }
                                            setState(() {});
                                          }),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "If yes, what is the reason for use?",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 5.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _cardOption("Self-medicating for medical purposes", double.maxFinite, _kindSelfMedical, () {
                                      setState(() {
                                        if (_kindSelfMedical) {
                                          _kindSelfMedical = false;
                                          _kindList.removeWhere((kind) => kind == "Self-medicating for medical purposes");
                                        } else {
                                          _kindSelfMedical = true;
                                          _kindList.add("Self-medicating for medical purposes");
                                        }
                                      });
                                    }),
                                    _cardOption(
                                        "Prescribed cannabis by a healthcare practitioner for medical purposes", double.maxFinite, _kindPrescribed,
                                        () {
                                      setState(() {
                                        if (_kindPrescribed) {
                                          _kindPrescribed = false;
                                          _kindList
                                              .removeWhere((kind) => kind == "Prescribed cannabis by a healthcare practitioner for medical purposes");
                                        } else {
                                          _kindPrescribed = true;
                                          _kindList.add("Prescribed cannabis by a healthcare practitioner for medical purposes");
                                        }
                                      });
                                    }),
                                    _cardOption("Recreational/adult use", double.maxFinite, _kindRecreational, () {
                                      setState(() {
                                        if (_kindRecreational) {
                                          _kindRecreational = false;
                                          _kindList.removeWhere((kind) => kind == "Recreational/adult use");
                                        } else {
                                          _kindRecreational = true;
                                          _kindList.add("Recreational/adult use");
                                        }
                                      });
                                    }),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "If yes, how often do you use cannabis?",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _cardOption("Daily", 140, _frequencyDaily, () {
                                          setState(() {
                                            if (_frequencyDaily) {
                                              _frequencyDaily = false;
                                              _frequency = "";
                                            } else {
                                              _frequencyDaily = true;
                                              _frequencyTimes = false;
                                              _frequencyWeek = false;
                                              _frequencyFortnight = false;
                                              _frequencyMonth = false;
                                              _frequency = "Daily";
                                            }
                                          });
                                        }),
                                        _cardOption("2-3 Times per week", 140, _frequencyTimes, () {
                                          setState(() {
                                            if (_frequencyTimes) {
                                              _frequencyTimes = false;
                                              _frequency = "";
                                            } else {
                                              _frequencyDaily = false;
                                              _frequencyTimes = true;
                                              _frequencyWeek = false;
                                              _frequencyFortnight = false;
                                              _frequencyMonth = false;
                                              _frequency = "2-3 Times per week";
                                            }
                                          });
                                        }),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _cardOption("Once a week", 140, _frequencyWeek, () {
                                          setState(() {
                                            if (_frequencyWeek) {
                                              _frequencyWeek = false;
                                              _frequency = "";
                                            } else {
                                              _frequencyDaily = false;
                                              _frequencyTimes = false;
                                              _frequencyWeek = true;
                                              _frequencyFortnight = false;
                                              _frequencyMonth = false;
                                              _frequency = "Once a week";
                                            }
                                          });
                                        }),
                                        Row(
                                          children: [
                                            _cardOption("Once a fortnight", 140, _frequencyFortnight, () {
                                              setState(() {
                                                if (_frequencyFortnight) {
                                                  _frequencyFortnight = false;
                                                  _frequency = "";
                                                } else {
                                                  _frequencyDaily = false;
                                                  _frequencyTimes = false;
                                                  _frequencyWeek = false;
                                                  _frequencyFortnight = true;
                                                  _frequencyMonth = false;
                                                  _frequency = "Once a fortnight";
                                                }
                                              });
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _cardOption("Once a month", 140, _frequencyMonth, () {
                                          setState(() {
                                            if (_frequencyMonth) {
                                              _frequencyMonth = false;
                                              _frequency = "";
                                            } else {
                                              _frequencyDaily = false;
                                              _frequencyTimes = false;
                                              _frequencyWeek = false;
                                              _frequencyFortnight = false;
                                              _frequencyMonth = true;
                                              _frequency = "Once a month";
                                            }
                                          });
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  //Drugs
  Widget _initDrugs(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_prefs.drugsResponse) {
      List<String> _drugsList = [];
      _prefs.drugsKind.forEach((kind) {
        _drugsList.add(kind);
      });
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: editMode ? Border.all(color: AppColor.fifthColor) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 25.0,
                            height: 25.0,
                            padding: EdgeInsets.only(left: size.width * 0.015, top: size.height * 0.004, bottom: size.height * 0.004),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                              child: Icon(
                                Icons.smoking_rooms,
                                color: Colors.white,
                                size: 15.0,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            "Drugs",
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: AppFontSizes.contentSmallSize,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.005),
                    _prefs.drugsConsume
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _drugsList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final kindSelected = _drugsList[index];
                                return Container(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    " •  " + kindSelected,
                                    style: TextStyle(
                                      color: AppColor.content,
                                      fontSize: AppFontSizes.contentSize,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 15.0, bottom: 5.0),
                            child: Text(
                              " •  Doesn't Consume",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.01),
            editMode
                ? InkWell(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 20.0,
                        width: 20.0,
                        margin: EdgeInsets.only(top: 2.5, right: 2.5),
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 12.0,
                        ),
                      ),
                    ),
                    onTap: () {
                      _showDrugsDialog(context, (
                        consume,
                        kind,
                      ) async {
                        _prefs.drugsConsume = consume;
                        _prefs.drugsKind = kind;
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      });
                    },
                  )
                : Container(),
          ],
        ),
      );
    } else {
      return Align(
        child: InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: size.width * 0.85,
              height: 60.0,
              decoration: BoxDecoration(
                gradient: AppColor.secondaryGradient,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20.0,
                    left: size.width * 0.035,
                    child: Text(
                      'Do you use any other recreational drugs?',
                      style: TextStyle(
                        color: AppColor.background,
                        fontSize: AppFontSizes.buttonSize + 3.0,
                      ),
                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                    ),
                  ),
                  Positioned(
                    top: 3.0,
                    left: size.width * 0.025,
                    child: Text(
                      'Do you use any other recreational drugs?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.1),
                        fontWeight: FontWeight.w900,
                        fontSize: AppFontSizes.buttonSize + 15.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            _showDrugsDialog(context, (
              consume,
              kind,
            ) async {
              setState(() async {
                final updateData = {
                  'patient_drugs': {
                    'drug_consume': consume,
                    'drug_kindOfUse': kind,
                  },
                };
                await updateProfile(context, updateData);
                Navigator.of(context).pop();
              });
            });
          },
        ),
      );
    }
  }

  void _showDrugsDialog(BuildContext context, Function(bool consume, List<String> kindList) callback) {
    final size = MediaQuery.of(context).size;
    bool _selectedYes = false;
    bool _selectedNo = false;
    bool _kindCocaine = false;
    bool _kindHeroin = false;
    bool _kindEcstasy = false;
    bool _kindPsilocybin = false;
    bool _kindLsd = false;
    bool _kindMushrooms = false;
    bool _kindNonNarcotincs = false;
    List<String> _kindList = [];
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 520,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    if (_selectedYes && _kindList.length > 0) {
                                      callback(_selectedYes, _kindList);
                                    } else if (_selectedNo) {
                                      callback(false, []);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 360.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Do you use any other recreational drugs?",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Card(
                                      elevation: 2.5,
                                      color: _selectedYes ? AppColor.secondaryColor : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: InkWell(
                                          child: SizedBox(
                                            width: size.width * 0.35,
                                            height: 50.0,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                  color: _selectedYes ? Colors.white : AppColor.primaryColor,
                                                  fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                                                ),
                                                textAlign: TextAlign.center,
                                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            if (_selectedYes) {
                                              _selectedYes = false;
                                            } else {
                                              _selectedYes = true;
                                              _selectedNo = false;
                                            }
                                            setState(() {});
                                          }),
                                    ),
                                    SizedBox(width: 10.0),
                                    Card(
                                      elevation: 2.5,
                                      color: _selectedNo ? AppColor.secondaryColor : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: InkWell(
                                          child: SizedBox(
                                            width: size.width * 0.35,
                                            height: 50.0,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                  color: _selectedNo ? Colors.white : AppColor.primaryColor,
                                                  fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                                                ),
                                                textAlign: TextAlign.center,
                                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            if (_selectedNo) {
                                              _selectedNo = false;
                                            } else {
                                              _selectedNo = true;
                                              _selectedYes = false;
                                              _kindList = [];
                                              _kindCocaine = false;
                                              _kindHeroin = false;
                                              _kindEcstasy = false;
                                              _kindPsilocybin = false;
                                              _kindLsd = false;
                                              _kindMushrooms = false;
                                              _kindNonNarcotincs = false;
                                            }
                                            setState(() {});
                                          }),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "If yes, what is the type you use?",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: 5.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _cardOption("Cocaine", 140, _kindCocaine, () {
                                          setState(() {
                                            if (_kindCocaine) {
                                              _kindCocaine = false;
                                              _kindList.removeWhere((kind) => kind == "Cocaine");
                                            } else {
                                              _kindCocaine = true;
                                              _kindList.add("Cocaine");
                                            }
                                          });
                                        }),
                                        _cardOption("Heroin", 140, _kindHeroin, () {
                                          setState(() {
                                            if (_kindHeroin) {
                                              _kindHeroin = false;
                                              _kindList.removeWhere((kind) => kind == "Heroin");
                                            } else {
                                              _kindHeroin = true;
                                              _kindList.add("Heroin");
                                            }
                                          });
                                        }),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _cardOption("Ecstasy (MDMA)", 140, _kindEcstasy, () {
                                          setState(() {
                                            if (_kindEcstasy) {
                                              _kindEcstasy = false;
                                              _kindList.removeWhere((kind) => kind == "Ecstasy (MDMA)");
                                            } else {
                                              _kindEcstasy = true;
                                              _kindList.add("Ecstasy (MDMA)");
                                            }
                                          });
                                        }),
                                        Row(
                                          children: [
                                            _cardOption("Psilocybin", 140, _kindPsilocybin, () {
                                              setState(() {
                                                if (_kindPsilocybin) {
                                                  _kindPsilocybin = false;
                                                  _kindList.removeWhere((kind) => kind == "Psilocybin");
                                                } else {
                                                  _kindPsilocybin = true;
                                                  _kindList.add("Psilocybin");
                                                }
                                              });
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _cardOption("LSD", 140, _kindLsd, () {
                                          setState(() {
                                            if (_kindLsd) {
                                              _kindLsd = false;
                                              _kindList.removeWhere((kind) => kind == "LSD");
                                            } else {
                                              _kindLsd = true;
                                              _kindList.add("LSD");
                                            }
                                          });
                                        }),
                                        Row(
                                          children: [
                                            _cardOption("Mushrooms", 140, _kindMushrooms, () {
                                              setState(() {
                                                if (_kindMushrooms) {
                                                  _kindMushrooms = false;
                                                  _kindList.removeWhere((kind) => kind == "Mushrooms");
                                                } else {
                                                  _kindMushrooms = true;
                                                  _kindList.add("Mushrooms");
                                                }
                                              });
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _cardOption("Non-Prescribed Narcotics", 140, _kindNonNarcotincs, () {
                                          setState(() {
                                            if (_kindNonNarcotincs) {
                                              _kindNonNarcotincs = false;
                                              _kindList.removeWhere((kind) => kind == "Non-Prescribed Narcotics");
                                            } else {
                                              _kindNonNarcotincs = true;
                                              _kindList.add("Non-Prescribed Narcotics");
                                            }
                                          });
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  Widget _cardOption(String text, double width, bool isSelected, VoidCallback callback) {
    return Card(
      elevation: 3.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          width: 2.0,
          color: isSelected ? AppColor.secondaryColor : Colors.transparent,
        ),
      ),
      child: InkWell(
        child: Container(
          width: width,
          height: 45.0,
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$text',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w300,
                  fontSize: AppFontSizes.contentSize - 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        onTap: callback,
      ),
    );
  }

  //CUSTOM SHOW DIALOGS
  void _showComsuptionMethodsDialog(BuildContext context, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    dataMedications.forEach((dataMedication) {
      dataMedication.isSelected = false;
      _medications.forEach((medication) {
        if (medication.title == dataMedication.title) {
          dataMedication.isSelected = true;
        }
      });
    });
    showProfileDialog(
        context,
        "Add Consumption Methods",
        150.0,
        Container(
          height: 150.0,
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Select your type product",
                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                  )),
              SizedBox(height: 2.5),
              Container(
                height: 120.0,
                width: size.width * 0.8,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: dataMedications.length,
                  itemBuilder: (BuildContext context, int index) {
                    final medication = dataMedications[index];
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return InkWell(
                          child: Container(
                            width: size.width * 0.28,
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(color: medication.isSelected ? AppColor.secondaryColor : AppColor.primaryColor)),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Image(
                                color: medication.isSelected ? AppColor.secondaryColor : AppColor.primaryColor,
                                height: 50.0,
                                width: 50.0,
                                image: AssetImage('assets/img/medication/${medication.icon}'),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                medication.title!,
                                style: TextStyle(
                                    color: medication.isSelected ? AppColor.background : AppColor.primaryColor,
                                    fontSize: AppFontSizes.contentSize - 1.0),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                          ),
                          onTap: () {
                            if (medication.isSelected) {
                              setState(() {
                                medication.isSelected = false;
                              });
                            } else {
                              _clearCard();
                              medication.preference = "";
                              medication.experience = "";
                              _showConsumptionMethodsOptionsDialog(context, medication, () {
                                print(">>>MEDICATION");
                                if (_emptyCard(medication)) {
                                  setState(() {
                                    medication.isSelected = true;
                                    Navigator.pop(context);
                                  });
                                }
                              });
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        callback);
  }

  void _showConsumptionMethodsOptionsDialog(BuildContext context, Medication medication, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 550.0,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      print("::Cancel");
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: callback,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 404.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Image(
                                        height: size.height * 0.05,
                                        width: size.width * 0.15,
                                        image: AssetImage('assets/img/medication/${medication.icon}'),
                                        fit: BoxFit.contain,
                                        color: AppColor.primaryColor,
                                      ),
                                      SizedBox(width: 10.0),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          "${medication.title}",
                                          style: TextStyle(
                                            color: AppColor.primaryColor,
                                            fontSize: AppFontSizes.subTitleSize + 5.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  "${medication.description}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: AppFontSizes.contentSize - 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20.0),
                                _preferencesOptions(medication, setState),
                                SizedBox(height: 15.0),
                                _experienceOptions(medication, setState),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  Widget _preferencesOptions(Medication medication, Function(void Function()) setState) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            "How do you feel about this method?",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: AppFontSizes.contentSize + 1.0,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: Row(
                children: [
                  Text(
                    "Love it",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.contentSize,
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Icon(Icons.check_circle_rounded, color: _selectedPreferenceLoveIt ? AppColor.secondaryColor : AppColor.content.withOpacity(0.3)),
                ],
              ),
              onTap: () {
                setState(() {
                  if (_selectedPreferenceLoveIt) {
                    _selectedPreferenceLoveIt = false;
                    medication.preference = "";
                  } else {
                    _selectedPreferenceLoveIt = true;
                    _selectedPreferenceLikeIt = false;
                    _selectedPreferenceItsOk = false;
                    medication.preference = "Love it";
                  }
                });
              },
            ),
            SizedBox(width: size.width * 0.06),
            InkWell(
              child: Row(
                children: [
                  Text(
                    "Like it",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.contentSize,
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Icon(Icons.check_circle_rounded, color: _selectedPreferenceLikeIt ? AppColor.secondaryColor : AppColor.content.withOpacity(0.3)),
                ],
              ),
              onTap: () {
                setState(() {
                  if (_selectedPreferenceLikeIt) {
                    _selectedPreferenceLikeIt = false;
                    medication.preference = "";
                  } else {
                    _selectedPreferenceLoveIt = false;
                    _selectedPreferenceLikeIt = true;
                    _selectedPreferenceItsOk = false;
                    medication.preference = "Like it";
                  }
                });
              },
            ),
            SizedBox(width: size.width * 0.06),
            InkWell(
              child: Row(
                children: [
                  Text(
                    "Dislike it",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.contentSize,
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Icon(Icons.check_circle_rounded, color: _selectedPreferenceItsOk ? AppColor.secondaryColor : AppColor.content.withOpacity(0.3)),
                ],
              ),
              onTap: () {
                setState(() {
                  if (_selectedPreferenceItsOk) {
                    _selectedPreferenceItsOk = false;
                    medication.preference = "";
                  } else {
                    _selectedPreferenceLoveIt = false;
                    _selectedPreferenceLikeIt = false;
                    _selectedPreferenceItsOk = true;
                    medication.preference = "Dislike it";
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _experienceOptions(Medication medication, Function(void Function()) setState) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            "How much experience do you have?",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: AppFontSizes.contentSize + 1.0,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _experienceCard("Novice", _selectedExperienceBeginner, () {
              setState(() {
                if (_selectedExperienceBeginner) {
                  _selectedExperienceBeginner = false;
                  medication.experience = "";
                } else {
                  _selectedExperienceBeginner = true;
                  _selectedExperienceAlittle = false;
                  _selectedExperienceAlot = false;
                  _selectedExperienceExpert = false;
                  medication.experience = "Novice";
                }
              });
            }),
            SizedBox(width: 10.0),
            _experienceCard("Intermediate", _selectedExperienceAlittle, () {
              setState(() {
                if (_selectedExperienceAlittle) {
                  _selectedExperienceAlittle = false;
                  medication.experience = "";
                } else {
                  _selectedExperienceBeginner = false;
                  _selectedExperienceAlittle = true;
                  _selectedExperienceAlot = false;
                  _selectedExperienceExpert = false;
                  medication.experience = "Intermediate";
                }
              });
            }),
          ],
        ),
        SizedBox(height: 7.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _experienceCard("Proficient", _selectedExperienceAlot, () {
              setState(() {
                if (_selectedExperienceAlot) {
                  _selectedExperienceAlot = false;
                  medication.experience = "";
                } else {
                  _selectedExperienceBeginner = false;
                  _selectedExperienceAlittle = false;
                  _selectedExperienceAlot = true;
                  _selectedExperienceExpert = false;
                  medication.experience = "Proficient";
                }
              });
            }),
            SizedBox(width: 10.0),
            _experienceCard("Expert", _selectedExperienceExpert, () {
              setState(() {
                if (_selectedExperienceExpert) {
                  _selectedExperienceExpert = false;
                  medication.experience = "";
                } else {
                  _selectedExperienceBeginner = false;
                  _selectedExperienceAlittle = false;
                  _selectedExperienceAlot = false;
                  _selectedExperienceExpert = true;
                  medication.experience = "Expert";
                }
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _experienceCard(String text, bool isSelected, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 3.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          width: 2.5,
          color: isSelected ? AppColor.secondaryColor : Colors.transparent,
        ),
      ),
      child: InkWell(
        child: SizedBox(
          width: size.width * 0.35,
          height: 40.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$text',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w300,
                  fontSize: AppFontSizes.contentSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        onTap: callback,
      ),
    );
  }

  bool _emptyCard(Medication modication) {
    if (modication.preference.isEmpty) {
      showAlertMessage(context, "Select how you feel about this method", () {
        Navigator.pop(context);
      });
      return false;
    } else {
      if (modication.experience.isEmpty) {
        showAlertMessage(context, "Select your experience level", () {
          Navigator.pop(context);
        });
        return false;
      } else {
        return true;
      }
    }
  }

  void _clearCard() {
    _selectedPreferenceLoveIt = false;
    _selectedPreferenceLikeIt = false;
    _selectedPreferenceItsOk = false;
    _selectedExperienceBeginner = false;
    _selectedExperienceAlittle = false;
    _selectedExperienceAlot = false;
    _selectedExperienceExpert = false;
  }

  Widget initInformationField(BuildContext context, double width, String icon, String title, String content, bool check, String iconForValidate,
      bool editable, VoidCallback? callback) {
    final size = MediaQuery.of(context).size;
    return Align(
      child: Container(
        width: width,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: editMode
              ? editable
                  ? Border.all(color: AppColor.fifthColor)
                  : null
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 25.0,
                            height: 25.0,
                            padding: EdgeInsets.only(left: size.width * 0.015),
                            child: Image(
                              color: editMode ? AppColor.content.withOpacity(0.25) : AppColor.primaryColor,
                              image: AssetImage('assets/img/profile/icon_profile_$icon.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: AppFontSizes.contentSmallSize,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.005),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text(
                        content,
                        style: TextStyle(
                          color: AppColor.content,
                          fontSize: AppFontSizes.contentSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            initInformationAcction(context, check, iconForValidate, editable, callback),
          ],
        ),
      ),
    );
  }

  Widget initInformationAcction(BuildContext context, bool check, String iconForValidate, bool editable, VoidCallback? callback) {
    final size = MediaQuery.of(context).size;
    if (editMode) {
      if (editable) {
        return InkWell(
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 20.0,
              width: 20.0,
              margin: EdgeInsets.only(top: 2.5, right: 2.5),
              decoration: BoxDecoration(
                color: AppColor.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 12.0,
              ),
            ),
          ),
          onTap: callback,
        );
      } else {
        return Container(
          padding: EdgeInsets.only(bottom: size.width * 0.05, left: size.width * 0.04, right: size.width * 0.04),
          child: Image(
            color: AppColor.content.withOpacity(0.25),
            image: AssetImage('assets/img/profile/icon_profile_$iconForValidate.png'),
          ),
        );
      }
    } else {
      return Container(
        padding: EdgeInsets.only(bottom: size.width * 0.05, left: size.width * 0.04, right: size.width * 0.04),
        child: Image(
          color: check ? AppColor.secondaryColor : AppColor.content.withOpacity(0.25),
          image: AssetImage('assets/img/profile/icon_profile_$iconForValidate.png'),
        ),
      );
    }
  }

  Widget initAditionalInformationField(BuildContext context, String title, String content, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    return Align(
      child: Container(
        width: size.width * 0.9,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: editMode ? Border.all(color: AppColor.fifthColor) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 5),
                      child: Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: AppFontSizes.contentSmallSize,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.005),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text(
                        content,
                        style: TextStyle(
                          color: AppColor.content,
                          fontSize: AppFontSizes.contentSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            initAditionalInformationAcction(callback),
          ],
        ),
      ),
    );
  }

  Widget initAditionalInformationAcction(VoidCallback callback) {
    if (editMode) {
      return InkWell(
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            height: 20.0,
            width: 20.0,
            margin: EdgeInsets.only(top: 2.5, right: 2.5),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 12.0,
            ),
          ),
        ),
        onTap: callback,
      );
    } else {
      return Container();
    }
  }

  ///////////
  //LOCATION
  Widget _initLocationgProfile(BuildContext context, UserPreference prefs) {
    final size = MediaQuery.of(context).size;
    final bloc = Provider.onboardingOf(context);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          _initTitleField(context, "Your Location"),
          SizedBox(height: size.height * 0.01),
          _initCountry(context),
          SizedBox(height: size.height * 0.01),
          _initPhoneNumber(context, bloc, size.width * 0.9),
          SizedBox(height: size.height * 0.01),
          _initStreet(context),
          SizedBox(height: size.height * 0.01),
          _initCity(context),
          SizedBox(height: size.height * 0.01),
          _initState(context),
          SizedBox(height: size.height * 0.01),
          _initZip(context),
          SizedBox(height: size.height * 0.02),
          Divider(height: 5.0, color: AppColor.primaryColor),
        ],
      ),
    );
  }

  Widget _initCountry(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool country = _prefs.country.isEmpty ? false : true;
    if (country) {
      return Container(
        height: 60,
        width: size.width * 0.9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: editMode ? Border.all(color: AppColor.fifthColor) : null,
          ),
          child: Row(
            children: [
              Expanded(child: Container()),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/${AppDataLocation().countryIcon(_prefs.country)}'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(15.0)),
              ),
              SizedBox(width: 25.0),
              Text(
                AppDataLocation().countryTitle(_prefs.country),
                style: TextStyle(
                  color: AppColor.content,
                  fontSize: AppFontSizes.contentSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Expanded(child: Container()),
              editMode
                  ? InkWell(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 20.0,
                          width: 20.0,
                          margin: EdgeInsets.only(top: 2.5, right: 2.5),
                          decoration: BoxDecoration(
                            color: AppColor.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 12.0,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showCountryDialog(context, () {
                          if (_prefs.country.isNotEmpty) {
                            setState(() async {
                              final updateData = {
                                'patient_address': {
                                  'country': _prefs.country,
                                  'state': _prefs.state,
                                },
                                'patient_contact': {
                                  'phone': _prefs.phonenumber,
                                },
                              };
                              await updateProfile(context, updateData);
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      },
                    )
                  : Container(),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  void _showCountryDialog(BuildContext context, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    height: size.height * 0.55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: size.height * 0.075,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w800),
                                  ),
                                  onPressed: () {
                                    callback();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: size.height * 0.05,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Select your Country",
                            style: TextStyle(
                              color: AppColor.content,
                              fontSize: AppFontSizes.subTitleSize,
                            ),
                          ),
                        ),
                        Container(
                          height: 120.0,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  child: Card(
                                    elevation: 2.5,
                                    color: _selectedUS ? AppColor.secondaryColor : AppColor.background,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(width: 1.5, color: _selectedUS ? AppColor.background : Colors.transparent),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage('assets/img/flag_us.png'),
                                                  fit: BoxFit.fill,
                                                ),
                                                borderRadius: BorderRadius.circular(15.0)),
                                          ),
                                          SizedBox(width: 5.0),
                                          Text(
                                            "United States",
                                            style: TextStyle(
                                                color: _selectedUS ? AppColor.background : AppColor.primaryColor,
                                                fontSize: AppFontSizes.contentSize - 1.0,
                                                fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (!_selectedUS) {
                                        _selectedUS = true;
                                        _prefs.country = 'US';
                                        _selectedAU = false;
                                        _prefs.phonenumber = "";
                                        _prefs.state = "";
                                      } else {
                                        _selectedUS = false;
                                        _prefs.country = '';
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Expanded(
                                child: InkWell(
                                  child: Card(
                                    elevation: 2.5,
                                    color: _selectedAU ? AppColor.secondaryColor : AppColor.background,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(width: 1.5, color: _selectedAU ? AppColor.background : Colors.transparent),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                      child: Row(children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage('assets/img/flag_au.png'),
                                                fit: BoxFit.fill,
                                              ),
                                              borderRadius: BorderRadius.circular(15.0)),
                                        ),
                                        SizedBox(width: 10.0),
                                        Text(
                                          "Australia",
                                          style: TextStyle(
                                              color: _selectedAU ? AppColor.background : AppColor.primaryColor,
                                              fontSize: AppFontSizes.contentSize - 1.0,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                      ]),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (!_selectedAU) {
                                        _selectedAU = true;
                                        _prefs.country = 'AU';
                                        _selectedUS = false;
                                        _prefs.phonenumber = "";
                                        _prefs.state = "";
                                      } else {
                                        _selectedAU = false;
                                        _prefs.country = '';
                                      }
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  Widget _initStreet(BuildContext context) {
    bool street = _prefs.street.isEmpty ? false : true;
    if (street) {
      return initLocationField(
        context,
        "Street",
        _prefs.street,
        () {
          _showStreetDialog(context, _prefs.street, () {
            if (_prefs.street.isNotEmpty) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "location", "Street", () {
        _showStreetDialog(context, "", () {
          if (_prefs.street.isNotEmpty) {
            setState(() async {
              final updateData = {
                'patient_address': {
                  'addressLine1': _prefs.ethnnicity,
                },
              };
              await updateProfile(context, updateData);
              Navigator.of(context).pop();
            });
          }
        });
      });
    }
  }

  void _showStreetDialog(BuildContext context, String lastStreet, VoidCallback callback) {
    final _prefs = new UserPreference();
    final _controller = new TextEditingController();
    bool editing = lastStreet.isEmpty ? true : false;
    if (editing) {
      _prefs.street = "";
    } else {
      _controller.text = lastStreet;
    }
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
                  "Street",
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
                  height: 120.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 10.0),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Enter your Street",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Material(
                        elevation: 2.5,
                        borderRadius: BorderRadius.circular(20.0),
                        child: TextField(
                          autofocus: true,
                          controller: _controller,
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Street",
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
                            _prefs.street = value;
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

  Widget _initCity(BuildContext context) {
    bool city = _prefs.city.isEmpty ? false : true;
    if (city) {
      return initLocationField(
        context,
        "City",
        _prefs.city,
        () {
          _showCityDialog(context, _prefs.city, () {
            if (_prefs.city.isNotEmpty) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "location", "City", () {
        _showCityDialog(context, "", () {
          if (_prefs.city.isNotEmpty) {
            setState(() async {
              final updateData = {
                'patient_address': {
                  'city': _prefs.city,
                },
              };
              await updateProfile(context, updateData);
              Navigator.of(context).pop();
            });
          }
        });
      });
    }
  }

  void _showCityDialog(BuildContext context, String lastCity, VoidCallback callback) {
    final _prefs = new UserPreference();
    final _controller = new TextEditingController();
    bool editing = lastCity.isEmpty ? true : false;
    if (editing) {
      _prefs.city = "";
    } else {
      _controller.text = lastCity;
    }
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
                  "City",
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
                  height: 120.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 10.0),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Enter your City",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Material(
                        elevation: 2.5,
                        borderRadius: BorderRadius.circular(20.0),
                        child: TextField(
                          autofocus: true,
                          controller: _controller,
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "City",
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
                            _prefs.city = value;
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

  Widget _initState(BuildContext context) {
    bool state = _prefs.state.isEmpty ? false : true;
    if (state) {
      return initLocationField(
        context,
        "State",
        _prefs.country == 'AU' ? AppDataLocation().statesAUTitle(_prefs.state)! : AppDataLocation().statesUSTitle(_prefs.state)!,
        () {
          _showStateDialog(context, _prefs.country == 'AU' ? AppDataLocation.dataStatesOfAustralian : AppDataLocation.dataStatesOfUnitedStates, () {
            if (_prefs.state.isNotEmpty) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "location", "State", () {
        _showStateDialog(context, _prefs.country == 'AU' ? AppDataLocation.dataStatesOfAustralian : AppDataLocation.dataStatesOfUnitedStates, () {
          if (_prefs.state.isNotEmpty) {
            setState(() async {
              final updateData = {
                'patient_address': {
                  'state': _prefs.state,
                },
              };
              await updateProfile(context, updateData);
              Navigator.of(context).pop();
            });
          }
        });
      });
    }
  }

  void _showStateDialog(BuildContext context, List<StateLocation> locationStates, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    height: size.height * 0.55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: size.height * 0.075,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                // TextButton(
                                //   child: Text(
                                //     "Save",
                                //     style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w800),
                                //   ),
                                //   onPressed: () {
                                //     //
                                //     // callback(_primaryConditions);
                                //     //
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: size.height * 0.05,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Select your State",
                            style: TextStyle(
                              color: AppColor.content,
                              fontSize: AppFontSizes.subTitleSize,
                            ),
                          ),
                        ),
                        Container(
                          height: size.height * 0.375,
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: Scrollbar(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: locationStates.length,
                              itemBuilder: (BuildContext context, int index) {
                                final state = locationStates[index];
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
                                        height: size.height * 0.05,
                                        width: size.width * 0.75,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            state.title!,
                                            style: TextStyle(
                                                color: AppColor.content, fontSize: AppFontSizes.contentSize - 1.0, fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        _prefs.state = state.abbreviation!;
                                        callback();
                                      },
                                    ),
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  Widget _initZip(BuildContext context) {
    bool zip = _prefs.zip.isEmpty ? false : true;
    if (zip) {
      return initLocationField(
        context,
        _prefs.country == 'AU' ? "Postal Code" : "Zip",
        _prefs.zip,
        () {
          _showZipDialog(context, _prefs.zip, () {
            if (_prefs.zip.isNotEmpty) {
              setState(() {
                Navigator.of(context).pop();
              });
            }
          });
        },
      );
    } else {
      return initProfileInfoEmptyField(context, "location", _prefs.country == 'AU' ? "Postal Code" : "Zip", () {
        _showZipDialog(context, "", () {
          if (_prefs.zip.isNotEmpty) {
            setState(() async {
              final updateData = {
                'patient_address': {
                  'zip': _prefs.zip,
                },
              };
              await updateProfile(context, updateData);
              Navigator.of(context).pop();
            });
          }
        });
      });
    }
  }

  void _showZipDialog(BuildContext context, String lastZip, VoidCallback callback) {
    final _prefs = new UserPreference();
    final _controller = new TextEditingController();
    bool editing = lastZip.isEmpty ? true : false;
    if (editing) {
      _prefs.zip = "";
    } else {
      _controller.text = lastZip;
    }
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
                  _prefs.country == 'AU' ? "Postal Code" : "Zip",
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
                  height: 120.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 10.0),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            _prefs.country == 'AU' ? "Enter your Postal Code" : "Enter your Zip",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Material(
                        elevation: 2.5,
                        borderRadius: BorderRadius.circular(20.0),
                        child: TextField(
                          autofocus: true,
                          controller: _controller,
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: _prefs.country == 'AU' ? "Postal Code" : "Zip",
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
                            _prefs.zip = value;
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

  Widget initLocationField(BuildContext context, String title, String content, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    return Align(
      child: Container(
        width: size.width * 0.9,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: editMode ? Border.all(color: AppColor.fifthColor) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 25.0,
                            height: 25.0,
                            padding: EdgeInsets.only(left: size.width * 0.015),
                            child: Image(
                              color: editMode ? AppColor.content.withOpacity(0.25) : AppColor.primaryColor,
                              image: AssetImage('assets/img/profile/icon_profile_location.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: AppFontSizes.contentSmallSize,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.005),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text(
                        content,
                        style: TextStyle(
                          color: AppColor.content,
                          fontSize: AppFontSizes.contentSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            initAditionalInformationAcction(callback),
          ],
        ),
      ),
    );
  }

  ///////////
  //SETTINGS
  Widget _initSettingProfile(BuildContext context, UserPreference prefs) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          _initTitleField(context, "Notification Settings"),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 25.0,
                          height: 25.0,
                          child: Icon(
                            Icons.notifications,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          "Notifications Timing",
                          style: TextStyle(
                            color: AppColor.content,
                            fontSize: AppFontSizes.contentSize,
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        editMode
                            ? Container(
                                width: 90.0,
                                height: 60.0,
                                margin: EdgeInsets.only(right: size.width * 0.025),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: editMode ? Border.all(color: AppColor.fifthColor) : null,
                                ),
                                child: ListWheelScrollView.useDelegate(
                                  itemExtent: 25.0,
                                  useMagnifier: true,
                                  magnification: 1.3,
                                  physics: FixedExtentScrollPhysics(),
                                  controller: FixedExtentScrollController(initialItem: dataNotificationTimes.indexOf(_prefs.timeNotifications)),
                                  childDelegate: ListWheelChildBuilderDelegate(builder: (BuildContext context, int index) {
                                    if (index < 0 || index > 3) {
                                      return null;
                                    } else {
                                      return Text(
                                        "${dataNotificationTimes[index]} min",
                                        style: TextStyle(
                                          color: AppColor.content,
                                          fontSize: AppFontSizes.contentSize,
                                        ),
                                      );
                                    }
                                  }),
                                  onSelectedItemChanged: (index) => {
                                    print(dataNotificationTimes[index]),
                                    _prefs.timeNotifications = dataNotificationTimes[index],
                                  },
                                ),
                              )
                            : Container(
                                width: 90.0,
                                height: 60.0,
                                margin: EdgeInsets.only(right: size.width * 0.025),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: editMode ? Border.all(color: AppColor.fifthColor) : null,
                                ),
                                child: Center(
                                  child: (Text(
                                    "${_prefs.timeNotifications.toString()} min",
                                    style: TextStyle(
                                      color: AppColor.content,
                                      fontSize: AppFontSizes.contentSize + 2.5,
                                    ),
                                  )),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          _initTitleField(context, "Communications Preferences"),
          SizedBox(height: size.height * 0.01),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 220.0,
              child: Text(
                "Relevant insight, news & offers",
                style: TextStyle(
                  color: AppColor.content,
                  fontWeight: FontWeight.w500,
                  fontSize: AppFontSizes.contentSize,
                ),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 25.0,
                          height: 25.0,
                          child: Icon(
                            Icons.email_rounded,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          "Email",
                          style: TextStyle(
                            color: AppColor.content,
                            fontSize: AppFontSizes.contentSize,
                          ),
                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        editMode
                            ? Switch(
                                value: _prefs.marketingEmail,
                                activeColor: AppColor.secondaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _prefs.marketingEmail = value;
                                  });
                                })
                            : Container(
                                width: 30.0,
                                height: 30.0,
                                child: Icon(
                                  _prefs.marketingEmail ? Icons.check_rounded : Icons.close_rounded,
                                  color: _prefs.marketingEmail ? AppColor.secondaryColor : AppColor.content,
                                ),
                              ),
                        SizedBox(width: size.width * 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 25.0,
                          height: 25.0,
                          child: Icon(
                            Icons.sms_rounded,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          "Text",
                          style: TextStyle(
                            color: AppColor.content,
                            fontSize: AppFontSizes.contentSize,
                          ),
                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        editMode
                            ? Switch(
                                value: _prefs.marketingText,
                                activeColor: AppColor.secondaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _prefs.marketingText = value;
                                  });
                                })
                            : Container(
                                width: 30.0,
                                height: 30.0,
                                child: Icon(
                                  _prefs.marketingText ? Icons.check_rounded : Icons.close_rounded,
                                  color: _prefs.marketingText ? AppColor.secondaryColor : AppColor.content,
                                ),
                              ),
                        SizedBox(width: size.width * 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          _initTitleField(context, "Communications"),
          SizedBox(height: size.height * 0.01),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "Inhale",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            editMode
                                ? Switch(
                                    value: _selectedDealsInhale,
                                    activeColor: AppColor.secondaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDealsInhale = value;
                                      });
                                    })
                                : Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: Icon(
                                      _selectedDealsInhale ? Icons.check_rounded : Icons.close_rounded,
                                      color: _selectedDealsInhale ? AppColor.secondaryColor : AppColor.content,
                                    ),
                                  ),
                            SizedBox(width: size.width * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "Vape",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            editMode
                                ? Switch(
                                    value: _selectedDealsVape,
                                    activeColor: AppColor.secondaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDealsVape = value;
                                      });
                                    })
                                : Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: Icon(
                                      _selectedDealsVape ? Icons.check_rounded : Icons.close_rounded,
                                      color: _selectedDealsVape ? AppColor.secondaryColor : AppColor.content,
                                    ),
                                  ),
                            SizedBox(width: size.width * 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "Topical",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            editMode
                                ? Switch(
                                    value: _selectedDealsTopical,
                                    activeColor: AppColor.secondaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDealsTopical = value;
                                      });
                                    })
                                : Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: Icon(
                                      _selectedDealsTopical ? Icons.check_rounded : Icons.close_rounded,
                                      color: _selectedDealsTopical ? AppColor.secondaryColor : AppColor.content,
                                    ),
                                  ),
                            SizedBox(width: size.width * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "Edibles",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            editMode
                                ? Switch(
                                    value: _selectedDealsEdibles,
                                    activeColor: AppColor.secondaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDealsEdibles = value;
                                      });
                                    })
                                : Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: Icon(
                                      _selectedDealsEdibles ? Icons.check_rounded : Icons.close_rounded,
                                      color: _selectedDealsEdibles ? AppColor.secondaryColor : AppColor.content,
                                    ),
                                  ),
                            SizedBox(width: size.width * 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "Tinctures",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            editMode
                                ? Switch(
                                    value: _selectedDealsTinctures,
                                    activeColor: AppColor.secondaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDealsTinctures = value;
                                      });
                                    })
                                : Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: Icon(
                                      _selectedDealsTinctures ? Icons.check_rounded : Icons.close_rounded,
                                      color: _selectedDealsTinctures ? AppColor.secondaryColor : AppColor.content,
                                    ),
                                  ),
                            SizedBox(width: size.width * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "Dabbing",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            editMode
                                ? Switch(
                                    value: _selectedDealsDabbing,
                                    activeColor: AppColor.secondaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDealsDabbing = value;
                                      });
                                    })
                                : Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: Icon(
                                      _selectedDealsDabbing ? Icons.check_rounded : Icons.close_rounded,
                                      color: _selectedDealsDabbing ? AppColor.secondaryColor : AppColor.content,
                                    ),
                                  ),
                            SizedBox(width: size.width * 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          Divider(height: 5.0, color: AppColor.primaryColor),
        ],
      ),
    );
  }

  ///////////
  //SECURITY
  Widget _initSecurityProfile(BuildContext context, UserPreference prefs) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          _initTitleField(context, "Your Account"),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60.0,
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: editMode ? Border.all(color: AppColor.fifthColor) : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Container(
                          width: 25.0,
                          height: 25.0,
                          child: Icon(
                            Icons.email,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(width: size.width * 0.05),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 0, top: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                      color: AppColor.primaryColor,
                                      fontSize: AppFontSizes.contentSmallSize,
                                    ),
                                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: size.width * 0.005),
                            Text(
                              _prefs.email,
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                            ),
                          ],
                        ),
                        editMode
                            ? Expanded(
                                child: Container(),
                              )
                            : Container(),
                        editMode
                            ? Container(
                                width: 40.0,
                                height: 40.0,
                                margin: EdgeInsets.only(right: size.width * 0.025),
                                decoration: BoxDecoration(
                                  color: AppColor.background,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: AppColor.secondaryColor),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: AppColor.secondaryColor,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          _initTitleField(context, "Password"),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60.0,
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: editMode ? Border.all(color: AppColor.fifthColor) : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Container(
                          width: 25.0,
                          height: 25.0,
                          child: Icon(
                            Icons.lock,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(width: size.width * 0.05),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 0, top: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "Password",
                                    style: TextStyle(
                                      color: AppColor.primaryColor,
                                      fontSize: AppFontSizes.contentSmallSize,
                                    ),
                                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: size.width * 0.005),
                            Text(
                              "**********",
                              style: TextStyle(
                                color: AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                              ),
                            ),
                          ],
                        ),
                        editMode
                            ? Expanded(
                                child: Container(),
                              )
                            : Container(),
                        editMode
                            ? Container(
                                width: 40.0,
                                height: 40.0,
                                margin: EdgeInsets.only(right: size.width * 0.025),
                                decoration: BoxDecoration(
                                  color: AppColor.background,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: AppColor.secondaryColor),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: AppColor.secondaryColor,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.03),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColor.secondaryColor,
              textStyle: TextStyle(fontSize: AppFontSizes.contentSize + 1.0),
            ),
            child: const Text(
              "Delete Account",
            ),
            onPressed: () {
              print("::Delete Account");
              showAlertMessageTwoAction(
                  context,
                  370.0,
                  "Delete Account",
                  "Are you sure you want to delete your account?\n\n You may reopen your account only within 30 days after you closed your account. After 30 days, you will not be able to reopen your account.",
                  "Confirm",
                  "Cancel", () async {
                final updateData = {
                  'patient_available': false,
                };
                await updateProfile(context, updateData);
                // Navigator.of(context).pop();

                _prefs.logout();
                Navigator.popAndPushNamed(context, 'signin');
              }, () => Navigator.pop(context));
            },
          ),
          SizedBox(height: size.height * 0.02),
          Divider(height: 5.0, color: AppColor.primaryColor),
        ],
      ),
    );
  }
}

//
//  Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             child: Container(
//               width: size.width * 0.75,
//               height: 60.0,
//               decoration: BoxDecoration(
//                 color: AppColor.background,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               child: Stack(
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         margin: EdgeInsets.only(left: size.width * 0.05, top: 5.0),
//                         width: size.width * 0.55,
//                         child: Text(
//                           "Button Option",
//                           style: TextStyle(
//                             color: AppColor.thirdColor,
//                             fontSize: AppFontSizes.buttonSize + 5.0,
//                             fontWeight: FontWeight.w900,
//                           ),
//                           textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
//                         ),
//                       ),
//                       Container(
//                         width: size.width * 0.15,
//                         height: double.maxFinite,
//                         child: Container(
//                           margin: EdgeInsets.all(size.width * 0.025),
//                           width: size.width * 0.1,
//                           height: size.width * 0.1,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(20),
//                             ),
//                             color: AppColor.fourthColor.withOpacity(0.15),
//                           ),
//                           child: Icon(
//                             Icons.arrow_forward_ios,
//                             size: 30.0,
//                             color: AppColor.secondaryColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Positioned(
//                     top: 3.5,
//                     left: size.width * 0.025,
//                     child: Text(
//                       "Button Option",
//                       style: TextStyle(
//                         color: AppColor.thirdColor.withOpacity(0.1),
//                         fontWeight: FontWeight.w900,
//                         fontSize: AppFontSizes.buttonSize + 15.0,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
