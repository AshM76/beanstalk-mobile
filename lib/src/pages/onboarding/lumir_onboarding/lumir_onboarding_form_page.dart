import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backgroundPaint_widget.dart';

import '../../../models/forms/rate_form_model.dart';
import '../../../models/forms/weekly_form_model.dart';
import '../../../services/authentication/auth_service.dart';
import '../../../services/forms/forms_service.dart';
import '../../../utils/loading.dart';
import '../../../utils/utils.dart';
import '../../../widgets/Onboarding/backButton_widget.dart';
import '../../../widgets/sessions/slider_theme_widget.dart';

class LumirOnboardingFormPage extends StatefulWidget {
  @override
  _LumirOnboardingFormPageState createState() => _LumirOnboardingFormPageState();
}

class _LumirOnboardingFormPageState extends State<LumirOnboardingFormPage> {
  final _prefs = new UserPreference();
  final _formServices = FormsServices();
  final authServices = AuthServices();

  List<WeeklyForm> weeklyForm = [];

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      _loadWeeklyForm(context);
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        initBackgroundPaint(context),
        _initInitialForm(context),
        backButton(context),
      ],
    ));
  }

  Widget _initInitialForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: _initTitle(),
              ),
              Padding(
                padding: EdgeInsets.only(left: size.width * 0.03, right: size.width * 0.06),
                child: _initQuestionaryForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initTitle() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            AppLogos.iconImg,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ),
          Container(
            height: 80.0,
            width: 300.0,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Initial Questionnaire",
                style: TextStyle(
                  color: AppColor.fourthColor,
                  fontSize: AppFontSizes.titleSize + 5.0,
                  fontFamily: AppFont.primaryFont,
                ),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initQuestionaryForm() {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
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
                      _initTitleQuestion(context, question.number.toString(), question.title!),
                      question.kind == 'rate' ? _initRateQuestion(question.rateResponse, question.rate!, index) : Container(),
                      SizedBox(height: size.height * 0.01),
                    ],
                  ),
                ),
              );
            }),
        SizedBox(height: size.height * 0.02),
        weeklyForm.length > 0 ? _initCompleteButton(context) : Container(),
      ],
    );
  }

  Widget _initTitleQuestion(BuildContext context, String numberSection, String textSection) {
    final size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30.0,
          child: Center(
            child: Text(
              numberSection,
              style: TextStyle(
                fontSize: AppFontSizes.titleSize,
                fontFamily: AppFont.primaryFont,
                color: AppColor.fourthColor,
              ),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.01),
        Image(
          color: AppColor.fifthColor,
          width: AppFontSizes.contentSize,
          image: AssetImage('assets/img/icon_arrow.png'),
          fit: BoxFit.contain,
        ),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(right: size.width * 0.125),
            child: Text(
              textSection,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              style: TextStyle(
                fontSize: AppFontSizes.contentSize - 1,
                color: AppColor.background,
              ),
              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initRateQuestion(int rate, RateForm rates, int index) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.075),
      child: Container(
        height: 75.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.content.withOpacity(0.15),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 7.5, vertical: 10.0),
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(
                Radius.circular(20),
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

  Widget _initCompleteButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        alignment: Alignment.bottomRight,
        padding: EdgeInsets.only(right: size.width * 0.05, bottom: size.height * 0.2),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(25.0),
          child: Container(
            width: size.width * 0.45,
            height: 50.0,
            child: Material(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(25.0),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.038),
                      child: Text(
                        "Complete",
                        style: TextStyle(
                          fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                          color: Colors.white,
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
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                onTap: () => _complete(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    bool questionValidate = true;
    weeklyForm.forEach((question) {
      if (!question.rated) {
        questionValidate = false;
      }
    });
    if (!questionValidate) {
      showAlertMessage(context, "Please rate all your question", () {
        Navigator.pop(context);
      });
      return false;
    }
    return true;
  }

  _complete(BuildContext context) async {
    if (_validateForm()) {
      _sendWeeklyForm(context);
    }
  }

  _sendWeeklyForm(BuildContext context) async {
    List<Map<String, dynamic>> weeklyFormResults = [];
    weeklyForm.forEach((element) {
      Map<String, dynamic> tempResponse = {
        'number': element.number,
        'kind': element.kind,
        'value': element.kind == 'rate' ? element.rateResponse : element.selectionResponse
      };
      weeklyFormResults.add(tempResponse);
    });

    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse = await _formServices.saveWeeklyForm(_prefs.id, "initialWeekly", "a387be09-bc58-45b1-9d3d-4bf158482a47", weeklyFormResults);
      if (infoResponse['ok']) {
        try {
          Map infoResponse = await authServices.onboarding();
          if (infoResponse['ok']) {
            progressDialog.dismiss();
            Navigator.of(context).pop();
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

  _loadWeeklyForm(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();

    final String _weeklyFormId = 'a387be09-bc58-45b1-9d3d-4bf158482a47'; //ModalRoute.of(context)?.settings?.arguments?.toString() ?? "weeklyForm";

    Map infoResponse = await _formServices.dataWeeklyForm(_weeklyFormId);

    if (infoResponse['ok']) {
      setState(() {
        //LOAD DATA FORM
        weeklyForm = [];
        final weeklyFormResult = infoResponse['weeklyForm']['form_structure'] ?? [];
        weeklyFormResult.forEach((question) {
          WeeklyForm tempQuestion = WeeklyForm.fromJson(question);
          weeklyForm.add(tempQuestion);
        });
        //Delete Question 9
        weeklyForm.removeLast();
        //Delete Question 8
        weeklyForm.removeLast();
        progressDialog.dismiss();
      });
    } else {
      progressDialog.dismiss();
      print("error load clinician info");
    }
  }
}
