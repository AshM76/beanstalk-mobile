import 'package:flutter/material.dart';

import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/datas/app_data_locations.dart';
import 'package:beanstalk_mobile/src/models/locations/location_state_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/phonenumber_validator.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/actionCardAdd_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/nextButton_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/fieldContent_widget.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backgroundPaint_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/titleForm_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/backButton_widget.dart';

class LumirOnboardingLocationPage extends StatefulWidget {
  @override
  _LumirOnboardingLocationPageState createState() => _LumirOnboardingLocationPageState();
}

class _LumirOnboardingLocationPageState extends State<LumirOnboardingLocationPage> {
  final _prefs = new UserPreference();

  bool _selectedUS = false;
  bool _selectedAU = false;
  bool _selectedPhoneNumber = false;
  bool _selectedStreet = false;
  bool _selectedCity = false;
  bool _selectedState = false;
  bool _selectedZip = false;

  @override
  void initState() {
    super.initState();
    clearLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: AppColor.background,
      child: Stack(
        children: <Widget>[
          initBackgroundPaint(context),
          _initLocationForm(context),
          backButton(context),
        ],
      ),
    ));
  }

  Widget _initLocationForm(BuildContext context) {
    final bloc = Provider.onboardingOf(context);
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              initTitle("Location Information"),
              SizedBox(height: size.height * 0.01),
              _initContry(context),
              SizedBox(height: size.height * 0.01),
              _initPhoneNumber(context, bloc),
              SizedBox(height: size.height * 0.01),
              _initStreet(context),
              SizedBox(height: size.height * 0.01),
              _initCity(context),
              SizedBox(height: size.height * 0.01),
              _initState(context),
              SizedBox(height: size.height * 0.01),
              _initZip(context),
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

  Widget _initContry(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Select Your Country",
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
            height: 60,
            width: size.width * 0.8,
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
                          _selectedPhoneNumber = false;
                          _prefs.phonenumber = "";
                          _selectedState = false;
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
                          _selectedPhoneNumber = false;
                          _prefs.phonenumber = "";
                          _selectedState = false;
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
  }

  Widget _initPhoneNumber(BuildContext context, OnboardingBloc bloc) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Phone Number",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _showPhoneNumberContent(context, bloc),
        ],
      ),
    );
  }

  Widget _showPhoneNumberContent(BuildContext context, OnboardingBloc bloc) {
    final size = MediaQuery.of(context).size;
    if (!_selectedPhoneNumber) {
      return Row(
        children: [
          ActionCardAdd("add", "icon_plusButton.png", size, () {
            setState(() {
              _prefs.country == 'AU'
                  ? _showPhoneNumberAUDialog(context, bloc, () {
                      int phonenumber = bloc.phonenumberAU.length;
                      if (phonenumber == 13) {
                        setState(() {
                          _selectedPhoneNumber = true;
                          _prefs.phonenumber = bloc.phonenumberAU;
                          Navigator.of(context).pop();
                        });
                      }
                    })
                  : _showPhoneNumberDialog(context, bloc, () {
                      int phonenumber = bloc.phonenumber.length;
                      if (phonenumber == 14) {
                        setState(() {
                          _selectedPhoneNumber = true;
                          _prefs.phonenumber = bloc.phonenumber;
                          Navigator.of(context).pop();
                        });
                      }
                    });
            });
          }),
        ],
      );
    } else {
      return showFieldContent(_prefs.phonenumber, 250.0, () {
        setState(() {
          _prefs.phonenumber = '';
          _selectedPhoneNumber = false;
        });
      });
    }
  }

  void _showPhoneNumberDialog(BuildContext context, OnboardingBloc bloc, VoidCallback callback) {
    bloc.changePhonenumber("");
    final _controllerPhoneNumber = new TextEditingController();
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
                  "Phone Number",
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
                                  contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                  errorText: snapshot.error as String?,
                                  errorStyle: TextStyle(fontSize: 10.0, color: Color.fromRGBO(157, 170, 134, 1.0)),
                                  focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                  errorBorder: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(10.0),
                                    margin: EdgeInsets.all(10.0),
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: _prefs.country == "AU" ? AssetImage('assets/img/flag_au.png') : AssetImage('assets/img/flag_us.png'),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: BorderRadius.circular(15.0)),
                                  ),
                                ),
                                onChanged: bloc.changePhonenumber,
                              );
                            }),
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

  void _showPhoneNumberAUDialog(BuildContext context, OnboardingBloc bloc, VoidCallback callback) {
    bloc.changePhonenumberAU("");
    final _controllerPhoneNumber = new TextEditingController();
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
                  "Phone Number",
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
                            "Enter your phone number",
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.grey[600]),
                          )),
                      SizedBox(height: 10.0),
                      Material(
                        elevation: 2.5,
                        borderRadius: BorderRadius.circular(20.0),
                        child: StreamBuilder(
                            stream: bloc.phonenumberAUStream,
                            builder: (context, snapshot) {
                              return TextFormField(
                                controller: _controllerPhoneNumber,
                                inputFormatters: [PhoneNumberAUTextInputFormatter()],
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "phone number",
                                  hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                  contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                  errorText: snapshot.error as String?,
                                  errorStyle: TextStyle(fontSize: 10.0, color: Color.fromRGBO(157, 170, 134, 1.0)),
                                  focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                  errorBorder: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(10.0),
                                    margin: EdgeInsets.all(10.0),
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: _prefs.country == "AU" ? AssetImage('assets/img/flag_au.png') : AssetImage('assets/img/flag_us.png'),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: BorderRadius.circular(15.0)),
                                  ),
                                ),
                                onChanged: bloc.changePhonenumberAU,
                              );
                            }),
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

  Widget _initStreet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Street",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _selectedStreet
              ? showFieldContent(_prefs.street, 250.0, () {
                  setState(() {
                    _prefs.street = '';
                    _selectedStreet = false;
                  });
                })
              : Row(
                  children: [
                    ActionCardAdd("add", "icon_plusButton.png", size, () {
                      setState(() {
                        _showStreetDialog(context, () {
                          setState(() {
                            if (_prefs.street != '') {
                              _selectedStreet = true;
                              Navigator.of(context).pop();
                            }
                          });
                        });
                      });
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  void _showStreetDialog(BuildContext context, VoidCallback callback) {
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
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "City",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _selectedCity
              ? showFieldContent(_prefs.city, 250.0, () {
                  setState(() {
                    _prefs.city = '';
                    _selectedCity = false;
                  });
                })
              : Row(
                  children: [
                    ActionCardAdd("add", "icon_plusButton.png", size, () {
                      setState(() {
                        _showCityDialog(context, () {
                          setState(() {
                            if (_prefs.city != '') {
                              _selectedCity = true;
                              Navigator.of(context).pop();
                            }
                          });
                        });
                      });
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  void _showCityDialog(BuildContext context, VoidCallback callback) {
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
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "State",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _selectedState
              ? showFieldContent(
                  _prefs.country == 'AU' ? AppDataLocation().statesAUTitle(_prefs.state)! : AppDataLocation().statesUSTitle(_prefs.state)!, 250.0,
                  () {
                  setState(() {
                    _prefs.state = '';
                    _selectedState = false;
                  });
                })
              : Row(
                  children: [
                    ActionCardAdd("add", "icon_plusButton.png", size, () {
                      setState(() {
                        _showStateDialog(
                            context, _prefs.country == 'AU' ? AppDataLocation.dataStatesOfAustralian : AppDataLocation.dataStatesOfUnitedStates, () {
                          setState(() {
                            if (_prefs.state != '') {
                              _selectedState = true;
                              Navigator.of(context).pop();
                            }
                          });
                        });
                      });
                    }),
                  ],
                ),
        ],
      ),
    );
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
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _prefs.country == 'AU' ? "Postal Code" : "Zip",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.subTitleSize,
            ),
            textAlign: TextAlign.left,
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
          ),
          _selectedZip
              ? showFieldContent(_prefs.zip, 250.0, () {
                  setState(() {
                    _prefs.zip = '';
                    _selectedZip = false;
                  });
                })
              : Row(
                  children: [
                    ActionCardAdd("add", "icon_plusButton.png", size, () {
                      setState(() {
                        _showZipDialog(context, () {
                          setState(() {
                            if (_prefs.zip != '') {
                              _selectedZip = true;
                              Navigator.of(context).pop();
                            }
                          });
                        });
                      });
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  void _showZipDialog(BuildContext context, VoidCallback callback) {
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

  bool _validateLocation() {
    if (_prefs.country == "") {
      showAlertMessage(context, "Please complete your country to continue", () {
        Navigator.pop(context);
      });
      return false;
    }
    // else if (_prefs.street == "") {
    //   showAlertMessage(context, "Please complete your street to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // } else if (_prefs.city == "") {
    //   showAlertMessage(context, "Please complete your city to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // } else if (_prefs.state == "") {
    //   showAlertMessage(context, "Please complete your state to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // } else if (_prefs.zip == "") {
    //   showAlertMessage(context, "Please complete your zip to continue", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // }

    return true;
  }

  void clearLocation() {
    _selectedUS = false;
    _selectedAU = false;

    _selectedPhoneNumber = false;
    _selectedStreet = false;
    _selectedCity = false;
    _selectedState = false;
    _selectedZip = false;

    _prefs.country = "";
    _prefs.phonenumber = "";
    _prefs.street = "";
    _prefs.city = "";
    _prefs.state = "";
    _prefs.zip = "";
  }

  _next(BuildContext context) async {
    if (_validateLocation()) {
      Navigator.pushNamed(context, 'onboarding_condition');
    }
  }
}
