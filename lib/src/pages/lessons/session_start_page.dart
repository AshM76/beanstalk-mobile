import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_measurement_model.dart';

import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_activeIngredients_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_method_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_species_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_conditions_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_terpenes_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/card/card_value_heightCard_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/slider_theme_widget.dart';

class SessionStartPage extends StatefulWidget {
  @override
  _SessionStartPageState createState() => _SessionStartPageState();
}

class _SessionStartPageState extends State<SessionStartPage> {
  final _prefs = new UserPreference();
  Session? _currentSession;

  List<Measurement> _dataDoseMeasurements = [];

  bool _addNote = false;
  TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      _clearStartSession();
      _loadDoseMeasurement();
    }();
  }

  _loadDoseMeasurement() {
    _dataDoseMeasurements = AppData().doseMeasurements(_currentSession!.productType!.title);
    _dataDoseMeasurements[0].isSelected = true;
    _currentSession!.doseMeasurement = _dataDoseMeasurements[0];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _currentSession = ModalRoute.of(context)!.settings.arguments as Session?;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.055),
        child: AppBar(
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
      ),
      body: Container(
        width: size.width,
        color: AppColor.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Start Session",
                    style: TextStyle(
                      fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                      fontFamily: AppFont.primaryFont,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              buildSessionCard(context, _currentSession!),
              SizedBox(height: size.height * 0.01),
              _initRateConditions(size, _currentSession!),
              _initRateDoses(size, _currentSession!),
              SizedBox(height: size.height * 0.02),
              _initNotes(context),
              _initStartSessionButton(context),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Card buildSessionCard(BuildContext context, Session currentSession) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Container(
        width: size.width * 0.785,
        height: valueHeightCard(size, currentSession),
        decoration: BoxDecoration(gradient: AppColor.primaryGradient, borderRadius: BorderRadius.circular(size.width * 0.05)),
        child: Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.012,
            left: size.width * 0.03,
            right: size.width * 0.03,
          ),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Session Info.",
                        style: TextStyle(
                          fontSize: AppFontSizes.subTitleSize,
                          color: AppColor.fifthColor,
                          fontFamily: AppFont.primaryFont,
                        ),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                      Expanded(child: Container()),
                      Text(
                        DateFormat('MM/dd/yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSmallSize,
                          color: AppColor.background,
                          fontFamily: AppFont.primaryFont,
                        ),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                    ],
                  ),
                  Divider(
                    height: size.width * 0.05,
                    thickness: 2,
                    color: AppColor.fifthColor.withOpacity(0.75),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  primaryConditionsCard(size, currentSession.primaryCondition!),
                  SizedBox(
                    height: size.height * 0.12,
                    child: VerticalDivider(
                      width: size.width * 0.05,
                      thickness: 2,
                      color: AppColor.thirdColor.withOpacity(0.5),
                      indent: size.height * 0.025,
                    ),
                  ),
                  infoConditionsCard(size, currentSession.secondaryCondition!),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  productTypeCard(size, currentSession.productType!),
                  SizedBox(
                    height: size.height * 0.12,
                    child: VerticalDivider(
                      width: size.width * 0.05,
                      thickness: 2,
                      color: AppColor.thirdColor.withOpacity(0.6),
                      indent: size.height * 0.025,
                    ),
                  ),
                  infoProductTypeCard(size, _currentSession!.deliveryMethodType!.title, _currentSession!.strainType!.title!),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  strainCard(size, currentSession.strainType),
                  SizedBox(
                    height: size.height * 0.12,
                    child: VerticalDivider(
                      width: size.width * 0.05,
                      thickness: 2,
                      color: AppColor.thirdColor.withOpacity(0.8),
                      indent: size.height * 0.025,
                    ),
                  ),
                  infoProductCard(size, _currentSession!.productBrand!, _currentSession!.productName!, _currentSession!.temperature!,
                      _currentSession!.temperatureMeasurement!.title), //36-°C
                ],
              ),
              SizedBox(height: size.height * 0.01),
              currentSession.cannabinoids!.length > 0
                  ? activeIngredientsCard(size, currentSession.cannabinoids!, currentSession.activeIngredientsMeasurement!.title, false)
                  : Container(),
              currentSession.terpenes!.length > 0
                  ? terpenesCard(size, currentSession.terpenes!, currentSession.activeIngredientsMeasurement!.title, false)
                  : Container(),
              // currentSession.sessionNote.length > 0 ? noteCard(size, currentSession.sessionNote) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initRateConditions(Size size, Session currentSession) {
    var allConditions = [...currentSession.primaryCondition!, ...currentSession.secondaryCondition!];
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.01,
              horizontal: size.width * 0.06,
            ),
            child: Text(
              "Rate the severity of your condition(s) from 0 (negligible) to 10 (severe)",
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content, fontWeight: FontWeight.w500),
              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: size.height * 0.01),
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: allConditions.length,
                padding: EdgeInsets.symmetric(vertical: size.height * 0.001),
                itemBuilder: (BuildContext context, int index) {
                  final condition = allConditions[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.01),
                    child: Row(
                      children: [
                        Container(
                          height: 90,
                          width: size.width * 0.25,
                          decoration: BoxDecoration(
                            color: AppColor.content.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: condition.title!.length > 10 ? 27.5 : 20.0,
                                  padding: EdgeInsets.symmetric(horizontal: 7.5),
                                  child: Center(
                                    child: Text(
                                      condition.title!,
                                      style: TextStyle(
                                          fontSize:
                                              condition.title!.length > 10 ? AppFontSizes.contentSmallSize - 1.5 : AppFontSizes.contentSize - 1.0,
                                          color: AppColor.primaryColor,
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Container(
                                  height: 50,
                                  width: size.width * 0.14,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${condition.value.toInt()}",
                                      style:
                                          TextStyle(fontSize: AppFontSizes.subTitleSize + 5.0, color: AppColor.content, fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 90,
                          width: size.width * 0.75,
                          child: Container(
                            margin: EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                              color: AppColor.content.withOpacity(0.2),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                bottomLeft: Radius.circular(25.0),
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 7.5, vertical: 17.5),
                              // width: size.width * 0.5,
                              // height: 60.0,
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                gradient: new LinearGradient(
                                    colors: [
                                      AppColor.fifthColor.withAlpha(200),
                                      AppColor.secondaryColor,
                                    ],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(1.0, 1.00),
                                    stops: [0.0, 1.0],
                                    tileMode: TileMode.clamp),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '0',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.subTitleSize + 2.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                    ),
                                    SizedBox(width: size.width * 0.005),
                                    Expanded(
                                      child: Center(
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            activeTrackColor: Colors.white.withOpacity(0.1),
                                            inactiveTrackColor: Colors.white.withOpacity(.1),
                                            trackHeight: 12.0,
                                            thumbShape: CustomSliderThumbCircle(
                                              thumbRadius: 22.5,
                                              min: 0,
                                              max: 10,
                                              decimal: false,
                                            ),
                                            thumbColor: AppColor.secondaryColor,
                                            overlayColor: Colors.white.withOpacity(.4),
                                            activeTickMarkColor: Colors.white,
                                            inactiveTickMarkColor: Colors.white.withOpacity(0.5),
                                            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                                            valueIndicatorColor: AppColor.secondaryColor,
                                            valueIndicatorTextStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: AppFontSizes.subTitleSize + 5.0,
                                            ),
                                          ),
                                          child: Slider(
                                            value: condition.value.toDouble(),
                                            min: 0,
                                            max: 10,
                                            divisions: 10,
                                            label: '${condition.value}',
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  condition.value = value.toInt();
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.005),
                                    Text(
                                      '10',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.subTitleSize + 2.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _initRateDoses(Size size, Session currentSession) {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.01,
              horizontal: size.width * 0.06,
            ),
            child: Text(
              "Enter the amount of cannabis (or medicine) you are consuming during this session",
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content, fontWeight: FontWeight.w500),
              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            ),
          ),
          _currentSession!.productBrand == 'Lumir'
              ? Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: size.height * 0.02),
                  height: 40.0,
                  child: Container(
                    width: size.width * 0.25,
                    decoration: BoxDecoration(
                      gradient: AppColor.secondaryGradient,
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      border: Border.all(color: AppColor.secondaryColor),
                    ),
                    child: Center(
                      child: Text(
                        _currentSession!.activeIngredientsMeasurement!.title!,
                        style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w800),
                        //
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.02),
                  height: 40.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _dataDoseMeasurements.length,
                    itemBuilder: (BuildContext context, int index) {
                      final measurement = _dataDoseMeasurements[index];
                      return InkWell(
                        child: Container(
                          width: size.width * 0.25,
                          decoration: BoxDecoration(
                            gradient: measurement.isSelected ? AppColor.secondaryGradient : null,
                            borderRadius:
                                _dataDoseMeasurements.length > 1 ? _initBorderDosesMeasurement(index) : BorderRadius.all(Radius.circular(15.0)),
                            border: Border.all(color: AppColor.secondaryColor),
                          ),
                          child: Center(
                            child: Text(
                              measurement.title!,
                              style: TextStyle(
                                  color: measurement.isSelected ? Colors.white : AppColor.secondaryColor,
                                  fontSize: AppFontSizes.contentSize,
                                  fontWeight: FontWeight.w800),
                              //
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_dataDoseMeasurements.length > 1) {
                            setState(() {
                              if (!measurement.isSelected) {
                                _dataDoseMeasurements.forEach((m) {
                                  m.isSelected = false;
                                });
                                measurement.isSelected = true;
                                _currentSession!.doseMeasurement = measurement;
                                currentSession.dose!.value = 0;
                              }
                              print("> Measurement: ${_currentSession!.doseMeasurement!.title}");
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
          Row(
            children: [
              Container(
                height: 90,
                width: size.width * 0.25,
                decoration: BoxDecoration(
                  color: AppColor.content.withOpacity(0.2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20.0,
                        padding: EdgeInsets.symmetric(horizontal: 2.5),
                        child: Text(
                          "${currentSession.doseMeasurement!.title}",
                          style: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.primaryColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        height: 50,
                        width: size.width * 0.14,
                        decoration: BoxDecoration(
                          color: AppColor.background,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: Text(
                            currentSession.doseMeasurement!.isDecimal
                                ? currentSession.dose!.value.toString()
                                : currentSession.dose!.value!.toInt().toString(),
                            style: TextStyle(fontSize: AppFontSizes.subTitleSize + 5.0, color: AppColor.content, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 90,
                width: size.width * 0.75,
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                    color: AppColor.content.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      bottomLeft: Radius.circular(25.0),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 7.5, vertical: 17.5),
                    // width: size.width * 0.5,
                    // height: 60.0,
                    decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.all(
                        Radius.circular(20),
                      ),
                      gradient: AppColor.secondaryGradient,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        children: [
                          Text(
                            currentSession.doseMeasurement!.isDecimal
                                ? currentSession.doseMeasurement!.minScale.toString()
                                : currentSession.doseMeasurement!.minScale.toInt().toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppFontSizes.subTitleSize + 2.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                          SizedBox(width: size.width * 0.005),
                          Expanded(
                            child: Center(
                              child: _loadSliderDose(currentSession),
                            ),
                          ),
                          SizedBox(width: size.width * 0.005),
                          Text(
                            currentSession.doseMeasurement!.isDecimal
                                ? currentSession.doseMeasurement!.maxScale.toString()
                                : currentSession.doseMeasurement!.maxScale.toInt().toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppFontSizes.subTitleSize + 2.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SliderTheme _loadSliderDose(Session currentSession) {
    double min = currentSession.doseMeasurement!.minScale;
    double max = currentSession.doseMeasurement!.maxScale;

    bool decimal = currentSession.doseMeasurement!.isDecimal;
    double div;
    if (decimal) {
      if (currentSession.doseMeasurement!.increment == 0.1) {
        div = currentSession.doseMeasurement!.maxScale * 10;
      } else {
        div = currentSession.doseMeasurement!.maxScale * 2;
      }
    } else {
      div = currentSession.doseMeasurement!.maxScale;
    }

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.white.withOpacity(0.1),
        inactiveTrackColor: Colors.white.withOpacity(.1),
        trackHeight: 12.0,
        thumbShape: CustomSliderThumbCircle(
          thumbRadius: 22.5,
          min: min,
          max: max,
          decimal: currentSession.doseMeasurement!.isDecimal,
        ),
        thumbColor: AppColor.secondaryColor,
        overlayColor: Colors.white.withOpacity(0.4),
        activeTickMarkColor: Colors.white,
        inactiveTickMarkColor: Colors.white.withOpacity(0.5),
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: AppColor.secondaryColor,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
          fontSize: AppFontSizes.subTitleSize + 5.0,
        ),
      ),
      child: Slider(
        value: currentSession.dose!.value == 0.0 ? min : currentSession.dose!.value!,
        min: min,
        max: max,
        divisions: div.toInt() - 1,
        label: currentSession.doseMeasurement!.isDecimal ? currentSession.dose!.value.toString() : currentSession.dose!.value!.toInt().toString(),
        onChanged: (value) {
          setState(
            () {
              if (decimal) {
                if (currentSession.doseMeasurement!.increment == 0.1) {
                  currentSession.dose!.value = value;
                } else {
                  currentSession.dose!.value = ((value * 2).floorToDouble() / 2);
                }
              } else {
                currentSession.dose!.value = value;
              }
              currentSession.dose!.position = 1;
            },
          );
        },
      ),
    );
  }

  BorderRadiusGeometry _initBorderDosesMeasurement(int index) {
    final size = MediaQuery.of(context).size;
    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(size.width * 0.025),
        bottomLeft: Radius.circular(size.width * 0.025),
      );
    } else if (_dataDoseMeasurements.length - 1 == index) {
      return BorderRadius.only(
        topRight: Radius.circular(size.width * 0.025),
        bottomRight: Radius.circular(size.width * 0.025),
      );
    } else {
      return BorderRadius.circular(0.0);
    }
  }

  Widget _initNotes(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      child: Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.02,
          left: size.width * 0.075,
          right: size.width * 0.075,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: _addNote
              ? Column(
                  children: [
                    Row(
                      children: [
                        Image(
                          color: AppColor.fifthColor,
                          width: AppFontSizes.subTitleSize - 2.0,
                          image: AssetImage('assets/img/icon_arrow.png'),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          "Notes",
                          style: TextStyle(
                            fontSize: AppFontSizes.subTitleSize - 2.0,
                            color: AppColor.content,
                          ),
                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01),
                    Container(
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(size.width * 0.025),
                        ),
                        border: Border.all(color: AppColor.content.withOpacity(0.5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
                          controller: _noteController,
                          minLines: 6, // any number you need (It works as the rows for the textarea)
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(200),
                          ],
                          maxLines: null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Write something here...",
                            hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2.0),
                            focusColor: Colors.amber,
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.05)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(size.width * 0.05),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Material(
                  elevation: 2.0,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(size.width * 0.025),
                  child: InkWell(
                    child: Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(size.width * 0.025),
                        ),
                        gradient: AppColor.secondaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: size.width * 0.025, right: size.width * 0.02),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 3.0,
                                left: size.width * 0.025,
                                child: Text(
                                  "Add Notes",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.1),
                                    fontSize: AppFontSizes.buttonSize + 10.0,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 15.0,
                                left: size.width * 0.02,
                                child: Text(
                                  "Add Notes",
                                  style: TextStyle(
                                    fontSize: AppFontSizes.buttonSize + 5.0,
                                    color: AppColor.background,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                ),
                              ),
                              Positioned(
                                top: 7.5,
                                right: size.width * 0.01,
                                child: Icon(
                                  Icons.add,
                                  size: 35.0,
                                  color: AppColor.background,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _addNote ? _addNote = false : _addNote = true;
                      });
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _initStartSessionButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      child: Container(
        height: 60.0,
        margin: EdgeInsets.only(
          right: size.width * 0.03,
          left: size.width * 0.03,
          top: size.height * 0.03,
          bottom: size.height * 0.03,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          gradient: AppColor.secondaryGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              offset: Offset(0.0, 1.0),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Row(
            children: [
              Text(
                "Start Session",
                style: TextStyle(
                  fontSize: AppFontSizes.buttonSize + 12.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
              Expanded(child: Container()),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppFontSizes.buttonSize + 25.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _currentSession!.sessionNote = _noteController.text;
        _startSession(context);
      },
    );
  }

  bool _validateStartSession() {
    bool conditionValidate = true;

    _currentSession!.primaryCondition!.forEach((condition) {
      if (condition.value <= 0) {
        conditionValidate = false;
      }
    });

    _currentSession!.secondaryCondition!.forEach((condition) {
      if (condition.value <= 0) {
        conditionValidate = false;
      }
    });

    if (!conditionValidate) {
      showAlertMessage(context, "Please rate your condition", () {
        Navigator.pop(context);
      });
      return false;
    } else if (_currentSession!.dose!.value! <= 0) {
      showAlertMessage(context, "Please enter the amount of cannabis you are consuming", () {
        Navigator.pop(context);
      });
      return false;
    }
    return true;
  }

  _startSession(BuildContext context) {
    if (_validateStartSession()) {
      print('session: $_currentSession');
      _currentSession!.sessionStatus = "active";
      _prefs.currentSession = jsonEncode(_currentSession!.toJson());
      Navigator.pushReplacementNamed(context, 'session_active');
    }
  }

  void _clearStartSession() {
    _dataDoseMeasurements = [];
    _dataDoseMeasurements.forEach((e) {
      e.isSelected = false;
    });
    _currentSession!.primaryCondition!.forEach((e) {
      e.value = 0;
    });
    _currentSession!.secondaryCondition!.forEach((e) {
      e.value = 0;
    });
    _currentSession!.dose!.value = 0;
    setState(() {});
  }
}
