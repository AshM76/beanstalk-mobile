import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/forms/rate_form_model.dart';
import 'package:beanstalk_mobile/src/models/forms/selection_form_model.dart';
import 'package:beanstalk_mobile/src/models/forms/weekly_form_model.dart';
import 'package:beanstalk_mobile/src/services/forms/forms_service.dart';

import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';

import '../../datas/app_data.dart';
import '../../models/canna_condition_model.dart';
import '../../models/forms/multiple_selection_form_model.dart';
import '../../models/forms/multiple_sub_selection_form_model.dart';
import '../../preferences/user_preference.dart';
import '../../utils/utils.dart';
import '../../widgets/forms/question_title_form_widget.dart';
import '../../widgets/sessions/slider_theme_widget.dart';

class WeeklyFormPage extends StatefulWidget {
  WeeklyFormPage({Key? key}) : super(key: key);

  @override
  _WeeklyFormPageState createState() => _WeeklyFormPageState();
}

class _WeeklyFormPageState extends State<WeeklyFormPage> {
  final _prefs = new UserPreference();
  final _formServices = FormsServices();

  String _currentWeeklyId = "";
  String _currentFormId = "";

  Condition condition = new Condition();

  List<WeeklyForm> weeklyForm = [];

  final _freeTextController = new TextEditingController();

  bool _sideEffectsResponse = false;
  bool _sideEffectsYes = false;
  bool _sideEffectsNo = false;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    () async {
      await Future.delayed(Duration.zero);
      _loadWeeklyForm(context);
    }();
    // formDataDummy.forEach((element) {e['value'] = 0;})
  }

  _loadUserPreferences() {
    List<Condition> tempComditions = [];
    _prefs.primaryConditions.forEach((condition) {
      Map<String, dynamic> temp = jsonDecode(condition);
      Condition tempCondition = Condition.fromJson(temp);
      tempComditions.add(tempCondition);
    });
    condition = tempComditions.last;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.066),
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
      body: SingleChildScrollView(
        child: Container(
            // height: size.height,
            width: size.width,
            color: AppColor.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Weekly Form",
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                        fontFamily: AppFont.primaryFont,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    "Please complete the form below:",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize + 1.0,
                      color: AppColor.content,
                      fontWeight: FontWeight.w700,
                    ),
                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                  child: Text(
                    "Current primary condition is:",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize,
                      color: AppColor.content,
                    ),
                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                  ),
                ),
                Container(
                  height: 75.0,
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                    borderRadius: BorderRadius.circular(size.width * 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(1.0, 1.0), //(x,y)
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -2.5,
                        right: -5.0,
                        child: Image.network(
                          AppLogos.iconImg,
                          opacity: const AlwaysStoppedAnimation(0.2),
                          // color: Colors.white.withOpacity(0.15),
                          width: size.width * 0.2,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(width: size.width * 0.05),
                          Container(
                            width: size.width * 0.2,
                            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                            child: Image(
                              color: AppColor.background,
                              image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Container(
                            width: size.width * 0.55,
                            child: Text(
                              condition.title!,
                              style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.subTitleSize + 1.0, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: weeklyForm.length,
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                    itemBuilder: (BuildContext context, int index) {
                      WeeklyForm question = weeklyForm[index];
                      return SingleChildScrollView(
                        child: Container(
                          child: Column(
                            children: [
                              TitleQuestionForm(context, question.number.toString(), question.title!),
                              _initQuestion(question, index),
                              SizedBox(height: size.height * 0.01),
                            ],
                          ),
                        ),
                      );
                    }),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'REMINDER: Please update your current therapeutics in your profile',
                      style: TextStyle(
                        fontSize: AppFontSizes.contentSize,
                        fontFamily: AppFont.primaryFont,
                        color: AppColor.content,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                weeklyForm.length > 0 ? _initContinueButton(context) : Container(),
                SizedBox(height: size.height * 0.2),
              ],
            )),
      ),
    );
  }

  Widget _initQuestion(WeeklyForm question, int questionIndex) {
    final size = MediaQuery.of(context).size;
    switch (question.kind) {
      case 'rate':
        return _initRateQuestion(question.rateResponse, question.rate!, questionIndex);
      case 'selection':
        return _initOptionQuestion(question.selection!, questionIndex);
      case 'multiple':
        return Column(
          children: [
            SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Row(
                children: [
                  Expanded(
                      child: Card(
                    elevation: 2.5,
                    color: _sideEffectsYes ? AppColor.secondaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.5),
                      side: BorderSide(width: 1.5, color: _sideEffectsYes ? AppColor.background : Colors.transparent),
                    ),
                    child: InkWell(
                      child: Container(
                        height: size.height * 0.05,
                        child: Center(
                          child: Text(
                            'Yes',
                            style: TextStyle(
                                color: _sideEffectsYes ? AppColor.background : AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (_sideEffectsYes) {
                          _sideEffectsResponse = false;
                          _sideEffectsYes = false;
                        } else {
                          _sideEffectsResponse = true;
                          _sideEffectsYes = true;
                          _sideEffectsNo = false;
                        }
                        setState(() {});
                      },
                    ),
                  )),
                  Expanded(
                      child: Card(
                    elevation: 2.5,
                    color: _sideEffectsNo ? AppColor.secondaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.5),
                      side: BorderSide(width: 1.5, color: _sideEffectsNo ? AppColor.background : Colors.transparent),
                    ),
                    child: InkWell(
                      child: Container(
                        height: size.height * 0.05,
                        child: Center(
                          child: Text(
                            'No',
                            style: TextStyle(
                                color: _sideEffectsNo ? AppColor.background : AppColor.content,
                                fontSize: AppFontSizes.contentSize,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (_sideEffectsNo) {
                          _sideEffectsResponse = false;
                          _sideEffectsNo = false;
                        } else {
                          _sideEffectsResponse = true;
                          _sideEffectsYes = false;
                          _sideEffectsNo = true;
                          question.multiple!.forEach((element) {
                            element.isSelected = false;
                            element.innerOptions!.forEach((subOption) {
                              subOption.isSelected = false;
                            });
                          });
                        }
                        setState(() {});
                      },
                    ),
                  ))
                ],
              ),
            ),
            _sideEffectsYes ? _initMultipleOptionQuestion(question.multiple!, questionIndex) : Container(height: size.height * 0.01),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _initRateQuestion(int rate, RateForm rates, int index) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: 25.0),
      child: Container(
        height: 70.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.content.withOpacity(0.15),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 7.5, vertical: 10.0),
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(
                Radius.circular(15.0),
              ),
              gradient: new LinearGradient(
                  colors: weeklyForm[index].rated
                      ? [
                          AppColor.fifthColor.withAlpha(200),
                          AppColor.secondaryColor,
                        ]
                      : [
                          AppColor.secondaryColor,
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
                    rates.minRate!,
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
                            min: double.parse(rates.minRate!),
                            max: double.parse(rates.maxRate!),
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
                          value: rate.toDouble(), //condition.value.toDouble(),
                          min: double.parse(rates.minRate!),
                          max: double.parse(rates.maxRate!),
                          divisions: int.parse(rates.maxRate!),
                          label: '$rate', //'${condition.value}',
                          onChanged: (value) {
                            setState(
                              () {
                                rate = value.toInt();
                                weeklyForm[index].rated = true;
                                weeklyForm[index].rateResponse = value.toInt();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.005),
                  Text(
                    rates.maxRate!,
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
    );
  }

  Widget _initOptionQuestion(List<SelectionForm> options, int questionIndex) {
    final size = MediaQuery.of(context).size;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: options.length,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) {
        final option = options[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Text(
                  option.option!,
                  style: TextStyle(
                    color: AppColor.content,
                    fontSize: AppFontSizes.contentSize,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
                Expanded(
                  child: Container(),
                ),
                Switch(
                    value: option.value,
                    activeColor: AppColor.secondaryColor,
                    onChanged: (value) {
                      setState(() {
                        options.forEach((e) {
                          e.value = false;
                        });
                        option.value = value;
                        if (value) {
                          weeklyForm[questionIndex].selectionResponse = option.option;
                        } else {
                          weeklyForm[questionIndex].selectionResponse = '';
                        }
                      });
                    }),
                SizedBox(width: size.width * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _initMultipleOptionQuestion(List<MultipleSelectionForm> options, int questionIndex) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.12, vertical: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final option = options[index];
          List<MultipleSubSelectionForm> subOptionsSelected = [];
          option.innerOptions!.forEach((element) {
            if (element.isSelected) {
              subOptionsSelected.add(element);
            }
          });
          return Card(
            elevation: 2.5,
            color: option.isSelected ? AppColor.secondaryColor : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.5),
              side: BorderSide(width: 1.5, color: option.isSelected ? AppColor.background : Colors.transparent),
            ),
            child: InkWell(
              child: Container(
                height: option.isSelected ? size.height * 0.06 + 20.0 + (size.height * 0.0525 * subOptionsSelected.length) : size.height * 0.06,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    option.isSelected ? SizedBox(height: size.height * 0.03) : SizedBox(height: size.height * 0.02),
                    Text(
                      option.option!,
                      style: TextStyle(
                          color: option.isSelected ? AppColor.background : AppColor.content,
                          fontSize: AppFontSizes.contentSize,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    option.isSelected
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: Divider(height: 5.0, color: AppColor.fifthColor),
                          )
                        : Container(),
                    option.isSelected ? _initSubOptionQuestion(option.innerOptions!) : Container(),
                  ],
                ),
              ),
              onTap: () {
                if (option.isSelected) {
                  option.isSelected = false;
                  option.innerOptions!.forEach((subOption) {
                    subOption.isSelected = false;
                  });
                  // additionalConditionsSelected.removeWhere((e) => e.title == additional.title);
                } else {
                  _showSubOptionsDialog(context, option, (option) {
                    if (option.option.toString().toLowerCase() == 'other') {
                      if (_freeTextController.text.trim().length > 0) {
                        option.isSelected = true;
                        option.innerOptions!.last.isSelected = true;
                        option.innerOptions!.last.option = _freeTextController.text;
                      }
                    } else {
                      option.isSelected = true;
                    }
                    // option.innerOptions.forEach((subOption) { add subOption});
                    Navigator.pop(context);
                    setState(() {});
                  });
                  // additionalConditionsSelected.add(additional);
                }
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }

  Widget _initSubOptionQuestion(List<MultipleSubSelectionForm> subOptions) {
    final size = MediaQuery.of(context).size;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: subOptions.length,
      itemBuilder: (BuildContext context, int index) {
        final subOption = subOptions[index];
        return subOption.isSelected
            ? Container(
                height: size.height * 0.05,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.005),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: size.width * 0.05),
                        Image(
                          color: AppColor.fifthColor.withOpacity(0.8),
                          width: AppFontSizes.contentSize,
                          image: AssetImage('assets/img/icon_arrow.png'),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: size.width * 0.02),
                        Container(
                          width: size.width * 0.6,
                          child: Text(
                            subOption.option!,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColor.background,
                              fontSize: AppFontSizes.contentSize,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Container();
      },
    );
  }

  void _showSubOptionsDialog(BuildContext context, MultipleSelectionForm option, Function(MultipleSelectionForm) callback) {
    final size = MediaQuery.of(context).size;
    _freeTextController.text = '';
    option.innerOptions!.forEach((o) {
      o.isSelected = false;
    });
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
                    padding: EdgeInsets.only(bottom: 0 + (MediaQuery.of(context).viewInsets.bottom / 3)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 450 + (MediaQuery.of(context).viewInsets.bottom / 3),
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
                                    callback(option);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 300,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      option.option!,
                                      style: TextStyle(
                                        color: AppColor.primaryColor,
                                        fontSize: AppFontSizes.contentSize + 2.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.5),
                                  child: Divider(height: 5.0, color: AppColor.primaryColor),
                                ),
                                Scrollbar(
                                  child: Container(
                                    height: 250,
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: option.innerOptions!.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final subOption = option.innerOptions![index];
                                        return option.option!.toLowerCase() != 'other'
                                            ? StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Card(
                                                    elevation: 2.5,
                                                    color: subOption.isSelected ? AppColor.secondaryColor : Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12.5),
                                                      side: BorderSide(
                                                          width: 1.5, color: subOption.isSelected ? AppColor.background : Colors.transparent),
                                                    ),
                                                    child: InkWell(
                                                      child: Container(
                                                        height: size.height * 0.055,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              option.innerOptions![index].option!,
                                                              style: TextStyle(
                                                                  color: subOption.isSelected ? AppColor.background : AppColor.content,
                                                                  fontSize: AppFontSizes.contentSize,
                                                                  fontWeight: FontWeight.w700),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                            option.isSelected
                                                                ? Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                                                    child: Divider(height: 5.0, color: AppColor.fifthColor),
                                                                  )
                                                                : Container(),
                                                            option.isSelected ? _initSubOptionQuestion(option.innerOptions!) : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        if (subOption.isSelected) {
                                                          subOption.isSelected = false;
                                                        } else {
                                                          subOption.isSelected = true;
                                                        }
                                                        setState(() {});
                                                      },
                                                    ),
                                                  );
                                                },
                                              )
                                            : Material(
                                                elevation: 2.5,
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: TextField(
                                                  autofocus: true,
                                                  controller: _freeTextController,
                                                  style: TextStyle(fontSize: AppFontSizes.contentSize, color: Colors.black),
                                                  keyboardType: TextInputType.text,
                                                  textCapitalization: TextCapitalization.sentences,
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      hintText: "Enter your side effect",
                                                      hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[300]),
                                                      errorText: null, //"\u26A0 email incorrecto",
                                                      contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                                                      focusedBorder:
                                                          OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                                                      enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide.none,
                                                        borderRadius: BorderRadius.circular(20.0),
                                                      ),
                                                      border: OutlineInputBorder(
                                                          borderRadius: new BorderRadius.circular(20.0),
                                                          borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                                      errorStyle: TextStyle(fontSize: 11.0)),
                                                ),
                                              );
                                      },
                                    ),
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

  Widget _initContinueButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.025,
        right: size.width * 0.025,
      ),
      child: Material(
        child: InkWell(
          child: Container(
            height: 70.0,
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              gradient: AppColor.secondaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: Row(
                children: [
                  Text(
                    "Send Results",
                    style: TextStyle(
                      fontSize: AppFontSizes.buttonSize + 10.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                  ),
                  Expanded(child: Container()),
                  Icon(
                    Icons.send_rounded,
                    size: AppFontSizes.buttonSize + 20.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            _sendWeeklyForm(context);
          },
        ),
      ),
    );
  }

  String? _responseQuestion(WeeklyForm question) {
    switch (question.kind) {
      case 'rate':
        return question.rateResponse.toString();
      case 'selection':
        return question.selectionResponse;
      case 'multiple':
        return jsonEncode(question.multipleResponse);
      default:
        return '';
    }
  }

  bool _validateForm() {
    bool questionRateValidate = true;
    bool questionOptionValidate = true;
    bool questionMultipleValidate = true;
    weeklyForm.forEach((question) {
      if (question.kind == "rate" && !question.rated) {
        questionRateValidate = false;
      }
      if (question.kind == "selection" && question.selectionResponse == '') {
        questionOptionValidate = false;
      }
      if (question.kind == "multiple" && !_sideEffectsResponse) {
        questionMultipleValidate = false;
      }
      if (question.kind == "multiple" && _sideEffectsResponse) {
        if (_sideEffectsYes) {
          if (question.multipleResponse!.length <= 0) {
            questionMultipleValidate = false;
          }
        }
      }
    });
    if (!questionRateValidate) {
      showAlertMessage(context, "Please rate all your question", () {
        Navigator.pop(context);
      });
      return false;
    } else if (!questionOptionValidate) {
      showAlertMessage(context, "Please select an option in question", () {
        Navigator.pop(context);
      });
      return false;
    } else if (!questionMultipleValidate) {
      showAlertMessage(context, "Please select if you have experiencing any side effects", () {
        Navigator.pop(context);
      });
      return false;
    }
    return true;
  }

  _loadWeeklyForm(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();

    final arguments = ModalRoute.of(context)?.settings.arguments as Map;

    _currentWeeklyId = arguments['weeklyId'].toString();
    _currentFormId = arguments['formId'].toString();

    Map infoResponse = await _formServices.dataWeeklyForm(_currentFormId);

    if (infoResponse['ok']) {
      setState(() {
        //LOAD DATA FORM
        weeklyForm = [];
        final weeklyFormResult = infoResponse['weeklyForm']['form_structure'] ?? [];
        weeklyFormResult.forEach((question) {
          WeeklyForm tempQuestion = WeeklyForm.fromJson(question);
          weeklyForm.add(tempQuestion);
        });
        progressDialog.dismiss();
      });
    } else {
      progressDialog.dismiss();
      print("error load clinician info");
    }
  }

  _sendWeeklyForm(BuildContext context) async {
    List<MultipleSelectionForm> tempExperiencingEffectsSelected = [];
    weeklyForm.forEach((question) {
      question.multipleResponse = [];
      if (question.kind == 'multiple' && _sideEffectsResponse) {
        question.multiple!.forEach((option) {
          if (option.isSelected) {
            MultipleSelectionForm optionSelected = new MultipleSelectionForm(option: option.option, isSelected: true, innerOptions: []);
            option.innerOptions!.forEach((subOption) {
              if (subOption.isSelected) {
                optionSelected.innerOptions!.add(subOption);
              }
            });
            tempExperiencingEffectsSelected.add(optionSelected);
          }
        });
        question.multipleResponse!.addAll(tempExperiencingEffectsSelected);
      }
    });
    if (_validateForm()) {
      List<Map<String, dynamic>> weeklyFormResults = [];
      weeklyForm.forEach((element) {
        Map<String, dynamic> tempResponse = {
          'number': element.number,
          'kind': element.kind,
          'value': _responseQuestion(element),
        };
        weeklyFormResults.add(tempResponse);
      });
      ProgressDialog progressDialog = ProgressDialog(context);
      progressDialog.show();
      try {
        Map infoResponse = await _formServices.saveWeeklyForm(_prefs.id, _currentWeeklyId, _currentFormId, weeklyFormResults);
        if (infoResponse['ok']) {
          progressDialog.dismiss();
          Navigator.pushReplacementNamed(context, 'navigation');
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
