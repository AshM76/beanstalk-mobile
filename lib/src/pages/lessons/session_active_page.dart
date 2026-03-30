import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/canna_feel_model.dart';
import 'package:beanstalk_mobile/src/models/canna_symptom_model.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/models/session_timeline_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/notifications/notification_service.dart';
import 'package:beanstalk_mobile/src/services/session/session_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSession/card_session_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSmall/cardSmall_activeIngredients_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSmall/cardSmall_conditions_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSmall/cardSmall_species_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSmall/cardsmall_product_type_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/slider_theme_widget.dart';

import '../../services/demo/demo_service.dart';

class SessionActivePage extends StatefulWidget {
  @override
  _SessionActivePageState createState() => _SessionActivePageState();
}

class _SessionActivePageState extends State<SessionActivePage> {
  final _prefs = new UserPreference();
  final sessionServices = SessionServices();

  Session? _currentSession;
  //Timer Session
  Duration _durationSession = Duration();
  Timer? _timerSession;
  //Timelines
  List<SessionTimeLine> _sessionTimeLines = [];
  ScrollController? _timeLineController;
  //Rate
  int _sessionRate = 0;
  //Dose
  int? _countDoses = 0;
  double? _tempDose = 0;
  double? _lastDose = 0;

  List<Condition> _sessionConditions = [];
  List<Condition> _tempConditions = [];
  List<List<Condition>> _lastRateConditions = [[], [], [], []];

  final _tempNote = TextEditingController();
  String? _tempFeeling = "";

  final List<Feel> _dataFeels = AppData.dataFeels;

  @override
  void initState() {
    super.initState();
    _durationSession = Duration();
    _timerSession = null;
    _sessionTimeLines = [];
    //Load Current Session
    Map<String, dynamic> temp = jsonDecode(_prefs.currentSession);
    _currentSession = Session.fromJson(temp);
    if (_prefs.activeSession) {
      continueTimerSession();
      _loadTimeLine(_currentSession, true);

      ///////
      ///////
      ///////
      List<dynamic> tempLastRateConditions = _prefs.lastRateSymptoms.length > 0 ? jsonDecode(_prefs.lastRateSymptoms) : [];
      for (var i = 0; i < tempLastRateConditions.length; i++) {
        if (tempLastRateConditions[i].length > 0) {
          List conditions = tempLastRateConditions[i];
          conditions.forEach((element) {
            Condition tempCondition = Condition.fromJson(element);
            _lastRateConditions[i].add(tempCondition);
          });
        }
      }
      ///////
      ///////
      ///////
      ///////

      () async {
        await Future.delayed(Duration.zero);
        verifyTimerSession();
      }();
    } else {
      () async {
        await Future.delayed(Duration.zero);
        showSetupNotificationTimingDialog(context, _prefs.timeNotifications, () {
          startTimerSession();
          _startTrackSession();
          _currentSession!.sessionStartTime = DateTime.now();
          _prefs.activeSession = true;
          _prefs.numberOfNotification = 0;
          saveSessionInUserPreference();
          _loadTimeLine(_currentSession, false);
          Navigator.of(context).pop();
        });
      }();
    }

    int tag = 0;
    var allConditions = [..._currentSession!.primaryCondition!, ..._currentSession!.secondaryCondition!];
    allConditions.forEach((condition) {
      condition.tag = tag;
      tag += 1;
      _sessionConditions.add(condition);
    });

    _timeLineController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timeLineController!
          .animateTo(_timeLineController!.position.minScrollExtent, duration: Duration(seconds: 1), curve: Curves.ease)
          .then((value) async {
        await Future.delayed(Duration(seconds: 1));
        _timeLineController!.animateTo(_timeLineController!.position.maxScrollExtent, duration: Duration(seconds: 1), curve: Curves.ease);
      });
    });
  }

  void startTimerSession() {
    print(":: START TIMER");
    _timerSession = Timer.periodic(Duration(seconds: 1), (_) => updateTimerSession());
  }

  void continueTimerSession() {
    print(":: CONTINUE TIMER");
    DateTime lastTimeSession = _currentSession!.sessionStartTime!;
    DateTime currentTime = DateTime.now();
    final timeSessionUpdate = currentTime.difference(lastTimeSession).inSeconds;

    _durationSession = Duration();
    _durationSession = Duration(seconds: timeSessionUpdate);
    _timerSession = Timer.periodic(Duration(seconds: 1), (_) => updateTimerSession());
  }

  void updateTimerSession() {
    final addSeconds = 1;
    if (mounted) {
      setState(() {
        final seconds = _durationSession.inSeconds + addSeconds;
        _durationSession = Duration(seconds: seconds);
        _prefs.numberOfNotification = _durationSession.inMinutes ~/ _prefs.lastTimeNotifications;
        verifyTimerSession();
      });
    }
  }

  void verifyTimerSession() {
    if (_durationSession.inHours >= 24) {
      _prefs.expiredTimeCurrentSession = true;
      _durationSession = Duration();
      _durationSession = Duration(hours: 24);
      _closeSession(true, Duration(hours: 24));
    }
  }

  void stopTimerSession() {
    _timerSession!.cancel();
  }

  void saveSessionInUserPreference() {
    _currentSession!.sessionTimeLines = _sessionTimeLines;
    _prefs.currentSession = jsonEncode(_currentSession!.toJson());
  }

  @override
  void dispose() {
    super.dispose();
    _timeLineController!.dispose();
    _tempNote.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(showSessionTime());
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
          // leading: IconButton(
          //   icon: Icon(
          //     Icons.arrow_back_ios_new_rounded,
          //     color: AppColor.content,
          //   ),
          //   onPressed: () => Navigator.of(context).pop(),
          // ),
        ),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        color: AppColor.background,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Active Session",
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                        fontFamily: AppFont.primaryFont,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Padding(
                  padding: EdgeInsets.only(
                    left: size.width * 0.025,
                    right: size.width * 0.025,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                          height: size.width * 0.7,
                          child: _timeCard(context),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          height: size.width * 0.7,
                          child: _sessionCard(context, _currentSession!),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: size.height * 0.41,
                  child: SingleChildScrollView(
                    controller: _timeLineController,
                    child: Column(
                      children: [
                        _initTimeline(size, _currentSession),
                        SizedBox(height: size.height * 0.175),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 130.0,
              right: 0.0,
              child: _initNewDosesButton(context),
              // child: Container(
              //   color: Colors.amber,
              //   height: 50.0,
              //   width: 50.0,
              // ),
            ),
            Positioned(
              bottom: 25.0,
              child: _iniSessionsOptionsBar(size),
            )
          ],
        ),
      ),
    );
  }

  //Time Card
  Widget _timeCard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 4.0,
      color: AppColor.background,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.1),
      ),
      child: Container(
        decoration: BoxDecoration(color: AppColor.content.withOpacity(0.15), borderRadius: BorderRadius.circular(size.width * 0.1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          "Start Time",
                          style: TextStyle(
                            fontSize: size.width * 0.032,
                            color: AppColor.content,
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Image(
                          color: AppColor.fifthColor,
                          width: 12.0,
                          image: AssetImage('assets/img/icon_arrow.png'),
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      height: size.width * 0.05,
                      margin: EdgeInsets.only(left: size.width * 0.01),
                      decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(size.width * 0.1)),
                      child: Center(
                        child: Text(
                          _currentSession!.sessionStartTime == null ? "" : DateFormat.jm().format(_currentSession!.sessionStartTime!),
                          style: TextStyle(
                            fontSize: size.width * 0.032,
                            color: AppColor.content,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.width * 0.01),
            Container(
              height: size.width * 0.4,
              width: size.width * 0.4,
              child: Container(
                decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(size.width * 0.2)),
                child: CircularPercentIndicator(
                    radius: size.height * 0.085,
                    lineWidth: size.width * 0.035,
                    percent: _durationSession.inMinutes >= 0 ? _valueGraphicTimer(_durationSession.inMinutes) : 0.0,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.005),
                        Text(
                          "Timer",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: AppColor.content,
                          ),
                        ),
                        Text(
                          showSessionTime(),
                          style: TextStyle(
                            fontSize: AppFontSizes.titleSize + 5.0,
                            color: AppColor.content,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _durationSession.inMinutes >= 60 ? "hrs" : "min",
                              style: TextStyle(
                                fontSize: AppFontSizes.contentSmallSize + 1.0,
                                color: AppColor.content,
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              _durationSession.inMinutes >= 60 ? "min" : "sec",
                              style: TextStyle(
                                fontSize: AppFontSizes.contentSmallSize + 1.0,
                                color: AppColor.content,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.002),
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.top,
                                child: Icon(
                                  Icons.notifications,
                                  size: 15,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              TextSpan(
                                text: _prefs.numberOfNotification > 0 ? "x${_prefs.numberOfNotification}" : "x0",
                                style: TextStyle(
                                  fontSize: AppFontSizes.contentSize - 1.0,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    backgroundColor: AppColor.content.withOpacity(0.2),
                    linearGradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: <Color>[
                      AppColor.secondaryColor,
                      AppColor.fifthColor,
                    ]),
                    rotateLinearGradient: true,
                    circularStrokeCap: CircularStrokeCap.round),
              ),
            ),
            SizedBox(height: size.width * 0.01),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: size.width * 0.027,
                            color: AppColor.content,
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Image(
                          color: AppColor.fifthColor,
                          width: 12.0,
                          image: AssetImage('assets/img/icon_arrow.png'),
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      height: size.width * 0.05,
                      margin: EdgeInsets.only(left: size.width * 0.01),
                      decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(size.width * 0.1)),
                      child: Center(
                        child: Text(
                          //TimeForSession
                          "${_prefs.lastTimeNotifications} min",
                          style: TextStyle(
                            fontSize: AppFontSizes.contentSize - 1.0,
                            color: AppColor.content,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _valueGraphicTimer(int minutes) {
    //TimeForSession
    final timerNotification = _prefs.lastTimeNotifications;
    final timeValue = minutes ~/ timerNotification;
    final value = timerNotification * timeValue;
    return ((minutes - value) / timerNotification);
  }

  //Session Card
  Widget _sessionCard(BuildContext context, Session currentSession) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.1),
        ),
        child: Container(
          decoration: BoxDecoration(gradient: AppColor.primaryGradient, borderRadius: BorderRadius.circular(size.width * 0.1)),
          child: Padding(
            padding: EdgeInsets.only(
              top: size.width * 0.0325,
              left: size.width * 0.03,
              right: size.width * 0.03,
            ),
            child: Column(
              children: [
                conditionsCardSmall(size, currentSession.primaryCondition!, true),
                productTypeCardSmall(size, currentSession.productType!, true),
                speciesCardSmall(size, currentSession.strainType, true),
                activeIngredientsCardSmall(size, currentSession.cannabinoids!, currentSession.activeIngredientsMeasurement!.title),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        print("Show Card Cannabis");
        showCardSession(context, currentSession);
      },
    );
  }

  //TimeLine
  _loadTimeLine(Session? currentSession, bool active) {
    if (active) {
      currentSession!.sessionTimeLines!.forEach((timeline) {
        _sessionTimeLines.add(timeline);
        if (timeline.type == "dose") {
          _countDoses = _countDoses! + 1;
        }
      });
    } else {
      _sessionConditions.forEach((condition) {
        _sessionTimeLines.add(
          SessionTimeLine(
            type: "condition",
            title: condition.title,
            value: condition.value.toDouble(),
            rate: condition.value,
            time: currentSession!.sessionStartTime,
          ),
        );
      });
      _countDoses = _currentSession!.dose!.position;
      _lastDose = _currentSession!.dose!.value;
      _sessionTimeLines.add(
        SessionTimeLine(
          type: "dose",
          value: _lastDose,
          position: _countDoses,
          time: currentSession!.sessionStartTime,
        ),
      );
    }
    saveSessionInUserPreference();
    setState(() {});
  }

  Widget _initTimeline(Size size, Session? currentSession) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _sessionTimeLines.length,
        padding: EdgeInsets.symmetric(vertical: size.height * 0.001),
        itemBuilder: (BuildContext context, int index) {
          final timeline = _sessionTimeLines[index];
          switch (timeline.type) {
            case "condition":
              return Container(
                height: 70,
                child: Container(
                  margin: EdgeInsets.only(left: size.width * 0.14, top: 5.0, bottom: 5.0),
                  child: Row(
                    children: [
                      index == 0 ? _initPointTimeline(size, true, timeline) : _initPointTimeline(size, false, timeline),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: AppColor.content.withOpacity(0.13),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: size.width * 0.16,
                                    child: Text(
                                      timeline.title == _sessionConditions.first.title ? "Primary Condition" : "Conditions",
                                      style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 5.0),
                                  Container(width: 1.5, color: AppColor.content.withOpacity(0.4)),
                                ],
                              ),
                              SizedBox(width: size.width * 0.02),
                              Container(
                                width: size.width * 0.3,
                                decoration: BoxDecoration(
                                  color: AppColor.background.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Center(
                                  child: Text(
                                    timeline.title!,
                                    style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    // textScaler: TextScaler.linear(AppFontScales.adaptiveScale - 0.5),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              Container(
                                width: size.width * 0.12,
                                decoration: BoxDecoration(
                                  color: AppColor.background.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 2.5),
                                    Text(
                                      "Rate",
                                      style: TextStyle(
                                        fontSize: AppFontSizes.contentSmallSize,
                                        color: AppColor.content,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "${timeline.value!.toInt()}",
                                      style: TextStyle(
                                          fontSize: AppFontSizes.contentSize + 5.0, color: AppColor.secondaryColor, fontWeight: FontWeight.w900),
                                      textAlign: TextAlign.center,
                                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case "note":
              return Container(
                height: 70,
                child: Container(
                  margin: EdgeInsets.only(left: size.width * 0.14, top: 5.0, bottom: 5.0),
                  child: Row(
                    children: [
                      _initPointTimeline(size, false, timeline),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: AppColor.content.withOpacity(0.13),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: size.width * 0.16,
                                    child: Text(
                                      "Note",
                                      style:
                                          TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.content, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 5.0),
                                  Container(width: 1.5, color: AppColor.content.withOpacity(0.4)),
                                ],
                              ),
                              SizedBox(width: size.width * 0.02),
                              Container(
                                width: size.width * 0.44,
                                decoration: BoxDecoration(
                                  color: AppColor.background.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Center(
                                  child: Text(
                                    timeline.title!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.contentSize - 1.0,
                                      color: AppColor.content,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case "feeling":
              return Container(
                height: 70,
                child: Container(
                  margin: EdgeInsets.only(left: size.width * 0.14, top: 5.0, bottom: 5.0),
                  child: Row(
                    children: [
                      _initPointTimeline(size, false, timeline),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: AppColor.content.withOpacity(0.13),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: size.width * 0.16,
                                    child: Text(
                                      "Feeling",
                                      style:
                                          TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.content, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 5.0),
                                  Container(width: 1.5, color: AppColor.content.withOpacity(0.4)),
                                ],
                              ),
                              SizedBox(width: size.width * 0.02),
                              Container(
                                width: size.width * 0.44,
                                decoration: BoxDecoration(
                                  color: AppColor.background.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Center(
                                  child: Text(
                                    timeline.title!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.contentSize,
                                      color: AppColor.content,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            default: // "dose"
              return Container(
                height: 70,
                child: Container(
                  margin: EdgeInsets.only(left: size.width * 0.14, top: 5.0, bottom: 5.0),
                  child: Row(
                    children: [
                      _initPointTimeline(size, false, timeline),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: AppColor.content.withOpacity(0.13),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: size.width * 0.16,
                                    child: Text(
                                      "Dose",
                                      style:
                                          TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.content, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 5.0),
                                  Container(width: 1.5, color: AppColor.content.withOpacity(0.4)),
                                ],
                              ),
                              SizedBox(width: size.width * 0.02),
                              Container(
                                width: size.width * 0.3,
                                decoration: BoxDecoration(
                                  color: AppColor.background.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      currentSession!.doseMeasurement!.isDecimal ? timeline.value.toString() : timeline.value!.toInt().toString(),
                                      style: TextStyle(fontSize: AppFontSizes.subTitleSize, color: AppColor.content, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                    ),
                                    Text(
                                      currentSession.doseMeasurement!.title.toString(),
                                      style: TextStyle(
                                        fontSize: AppFontSizes.contentSize - 1.0,
                                        color: AppColor.content,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              Container(
                                width: size.width * 0.12,
                                decoration: BoxDecoration(
                                  color: AppColor.background.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 2.5),
                                    Text(
                                      "Dose",
                                      style: TextStyle(
                                        fontSize: AppFontSizes.contentSmallSize,
                                        color: AppColor.content,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      _setDosesPosition(timeline.position),
                                      style: TextStyle(
                                          fontSize: AppFontSizes.titleSize - 3.5, color: AppColor.secondaryColor, fontWeight: FontWeight.w900),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
          }
        });
  }

  Container _initPointTimeline(Size size, bool start, SessionTimeLine timeline) {
    return Container(
      width: size.width * 0.18,
      child: Row(
        children: [
          start
              ? Container(
                  width: size.width * 0.09,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Session",
                        style: TextStyle(
                          fontSize: size.width * 0.023,
                          color: AppColor.content,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Start",
                        style: TextStyle(fontSize: AppFontSizes.contentSize - 1.5, color: AppColor.content, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                )
              : Container(
                  width: size.width * 0.09,
                  child: Text(
                    showSessionTimeline(timeline.time!.toLocal()),
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSmallSize,
                      color: AppColor.content,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
          start ? SizedBox(width: 3.0) : SizedBox(width: 11.0),
          start
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: size.width * 0.04,
                      height: size.width * 0.04,
                      decoration: BoxDecoration(
                        color: AppColor.fifthColor,
                        borderRadius: BorderRadius.circular(size.width * 0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: size.height * 0.025,
                      child: CustomPaint(size: Size(1, double.infinity), painter: DashedLineVerticalPainter()),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      height: 70.0,
                      child: CustomPaint(size: Size(1, double.infinity), painter: DashedLineVerticalPainter()),
                    ),
                    SizedBox(width: size.width * 0.0025),
                    Center(
                      child: Container(
                        width: size.width * 0.04,
                        height: size.width * 0.04,
                        child: Image(
                          color: AppColor.fifthColor,
                          width: size.width * 0.03,
                          image: AssetImage('assets/img/icon_arrow.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
          SizedBox(width: 5.0),
        ],
      ),
    );
  }

  //Session Options Bar
  Widget _iniSessionsOptionsBar(Size size) {
    return Container(
      height: 90.0,
      width: size.width,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 2.5),
          decoration: BoxDecoration(
            color: AppColor.background,
            borderRadius: BorderRadius.circular(size.width * 0.05),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Row(
            children: [
              InkWell(
                child: Container(
                  width: 65.0,
                  margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: AppColor.background,
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10.0,
                        left: 12.5,
                        child: Image(
                          height: 40.0,
                          width: 40.0,
                          image: AssetImage('assets/img/icon_signout.png'),
                          color: AppColor.secondaryColor,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        bottom: 7.0,
                        child: Container(
                          width: 65.0,
                          child: Text('End Session',
                              style: TextStyle(
                                  fontSize: AppFontSizes.contentSmallSize - 1.0, color: AppColor.secondaryColor, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  /////
                  ////////
                  showAlertMessageTwoAction(context, 210.0, "End Session?", "Select End to confirm", "End", "Cancel", () {
                    print("End Session");
                    Navigator.pop(context);
                    _showSessionSheet(300.0, "Save", _initRateSessionModal(), () {
                      print("Rate Session");
                      _closeSession(false, Duration());
                    });
                  }, () {
                    print("Cancel Session");
                    Navigator.pop(context);
                  });
                  ////////
                  /////
                },
              ),
              Expanded(child: Container()),
              _initButtonOptionBar(size, "icon_condition", "Conditions", Icons.refresh, () {
                _showSessionSheet(_valueHeightSheet(_sessionConditions.length), "Update", _initUpdateSymptomsModal(), () {
                  print("Update Conditions");

                  for (var i = 0; i < _tempConditions.length; i++) {
                    if (_lastRateConditions[i].length > 0) {
                      if (_tempConditions[i].value != _lastRateConditions[i].last.value) {
                        _sessionTimeLines.add(SessionTimeLine(
                          type: "condition",
                          title: _tempConditions[i].title,
                          value: _tempConditions[i].value.toDouble(),
                          rate: _tempConditions[i].value,
                          time: DateTime.now(),
                        ));
                        _lastRateConditions[_tempConditions[i].tag].add(_tempConditions[i]);
                        _prefs.lastRateSymptoms = jsonEncode(_lastRateConditions);
                        _updatePositionTimeLine();
                      }
                    } else {
                      _sessionTimeLines.add(SessionTimeLine(
                        type: "condition",
                        title: _tempConditions[i].title,
                        value: _tempConditions[i].value.toDouble(),
                        rate: _tempConditions[i].value,
                        time: DateTime.now(),
                      ));
                      _lastRateConditions[_tempConditions[i].tag].add(_tempConditions[i]);
                      _prefs.lastRateSymptoms = jsonEncode(_lastRateConditions);
                      _updatePositionTimeLine();
                    }
                  }
                  setState(() {});
                  saveSessionInUserPreference();
                  Navigator.pop(context);
                });
              }),
              _initButtonOptionBar(size, "icon_notes", "Notes", Icons.add, () {
                _showSessionSheet(300.0, "Save", _initAddNotesModal(), () {
                  print("Add Note");
                  if (_tempNote.text != "") {
                    _sessionTimeLines.add(SessionTimeLine(
                      type: "note",
                      title: _tempNote.text,
                      time: DateTime.now(),
                    ));
                    _updatePositionTimeLine();
                    _tempNote.clear();
                    // setState(() {});
                    saveSessionInUserPreference();
                    Navigator.pop(context);
                  }
                });
                // showProfileDialog(context, "Add Consumption Methods", 160.0,
                //     _initNotesModal(), () {});
              }),
              _initButtonOptionBar(size, "icon_feel_good", "Feels", Icons.add, () {
                _showSessionSheet(300.0, "Save", _initAddFeelingsModal(), () {
                  print("Add Feel");
                  _sessionTimeLines.add(SessionTimeLine(
                    type: "feeling",
                    title: _tempFeeling,
                    time: DateTime.now(),
                  ));
                  _updatePositionTimeLine();
                  _tempFeeling = "";
                  setState(() {});
                  saveSessionInUserPreference();
                  Navigator.pop(context);
                });
              }),
            ],
          )),
    );
  }

  Widget _initButtonOptionBar(Size size, String image, String title, IconData icon, VoidCallback callback) {
    return InkWell(
      child: Container(
        width: 65.0,
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        decoration: BoxDecoration(
          gradient: AppColor.secondaryGradient,
          borderRadius: BorderRadius.circular(size.width * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12.5,
              left: 12.5,
              child: Image(
                height: 40.0,
                width: 40.0,
                image: AssetImage('assets/img/$image.png'),
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 3.0,
              right: 3.0,
              child: Container(
                height: 22.0,
                width: 22.0,
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
            Positioned(
              bottom: 7.0,
              child: Container(
                width: 65.0,
                child: Text(title,
                    style: TextStyle(fontSize: AppFontSizes.contentSmallSize - 1.0, color: Colors.white, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
      onTap: callback,
    );
  }

  //New Dose Button
  Widget _initNewDosesButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      child: Container(
        height: 70.0,
        width: size.width * 0.7,
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          color: AppColor.secondaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Row(
            children: [
              Text(
                "New Doses",
                style: TextStyle(
                  fontSize: AppFontSizes.buttonSize + 10.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                //
              ),
              Expanded(child: Container()),
              Icon(
                Icons.add_rounded,
                size: AppFontSizes.buttonSize + 30.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        print("Start Session");
        _showSessionSheet(300, "Save", _initNewDoseModal(), () {
          print("New Dose");
          _countDoses = _countDoses! + 1;
          _sessionTimeLines.add(SessionTimeLine(
            type: "dose",
            value: _currentSession!.dose!.value,
            position: _countDoses,
            time: DateTime.now(),
          ));
          _lastDose = _tempDose;
          _updatePositionTimeLine();
          setState(() {});
          saveSessionInUserPreference();
          Navigator.pop(context);
          showAlertMessageTwoAction(context, 220.0, "Update Your Conditions?",
              "Would you like to update your condition(s) to get more accurate session tracking?", "Update", "Cancel", () {
            Navigator.pop(context);
            _showSessionSheet(_valueHeightSheet(_sessionConditions.length), "Update", _initUpdateSymptomsModal(), () {
              print("Update Conditions");
              for (var i = 0; i < _tempConditions.length; i++) {
                if (_lastRateConditions[i].length > 0) {
                  if (_tempConditions[i].value != _lastRateConditions[i].last.value) {
                    _sessionTimeLines.add(SessionTimeLine(
                      type: "condition",
                      title: _tempConditions[i].title,
                      value: _tempConditions[i].value.toDouble(),
                      rate: _tempConditions[i].value,
                      time: DateTime.now(),
                    ));
                    _lastRateConditions[_tempConditions[i].tag].add(_tempConditions[i]);
                    _prefs.lastRateSymptoms = jsonEncode(_lastRateConditions);
                    _updatePositionTimeLine();
                  }
                } else {
                  _sessionTimeLines.add(SessionTimeLine(
                    type: "condition",
                    title: _tempConditions[i].title,
                    value: _tempConditions[i].value.toDouble(),
                    rate: _tempConditions[i].value,
                    time: DateTime.now(),
                  ));
                  _lastRateConditions[_tempConditions[i].tag].add(_tempConditions[i]);
                  _prefs.lastRateSymptoms = jsonEncode(_lastRateConditions);
                  _updatePositionTimeLine();
                }
              }
              setState(() {});
              saveSessionInUserPreference();
              Navigator.pop(context);
            });
          }, () {
            Navigator.pop(context);
          });
        });
      },
    );
  }

  _closeSession(bool expiredTime, Duration expiredDuration) {
    stopTimerSession();
    DateTime tempTime;
    if (expiredTime) {
      tempTime = _currentSession!.sessionStartTime!.add(expiredDuration);
    } else {
      tempTime = DateTime.now();
    }
    for (var i = 0; i < _sessionConditions.length; i++) {
      if (_lastRateConditions[i].length > 0) {
        if (_lastRateConditions[i].last.value != 0) {
          _sessionTimeLines.add(SessionTimeLine(
            type: "condition",
            title: _lastRateConditions[i].last.title,
            value: _lastRateConditions[i].last.value.toDouble(),
            rate: _lastRateConditions[i].last.value,
            time: tempTime,
          ));
        }
      } else {
        _sessionTimeLines.add(SessionTimeLine(
          type: "condition",
          title: _sessionConditions[i].title,
          value: _sessionConditions[i].value.toDouble(),
          rate: _sessionConditions[i].value,
          time: tempTime,
        ));
      }
    }

    _currentSession!.sessionTimeLines = _sessionTimeLines;
    _currentSession!.sessionRate = _sessionRate;
    if (expiredTime) {
      _currentSession!.sessionEndTime = _currentSession!.sessionStartTime!.add(expiredDuration);
    } else {
      _currentSession!.sessionEndTime = DateTime.now();
    }
    _currentSession!.sessionDurationTime = DateTime(0000, 00, 00, 0, 0, _durationSession.inSeconds);
    _currentSession!.sessionDurationParameter = _setDurationParamenter(_currentSession!.sessionDurationTime!);

    _stopTrackSession();
    _currentSession!.sessionStatus = "stored";

    if (_prefs.demoVersion) {
      showAlertMessage(context, 'Session not saved in demo version', () {
        Navigator.pop(context);
        _saveSession(context);
      });
    } else {
      _saveSession(context);
    }

    _clearSession();
  }

  _saveSession(BuildContext context) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse = _prefs.demoVersion ? await demoService.loadSession(_prefs.id) : await sessionServices.saveSession(_currentSession!);
      if (infoResponse['ok']) {
        progressDialog.dismiss();
        _currentSession = infoResponse['session'];
        _currentSession!.sessionStatus = "firstTime";
        Navigator.pushNamed(context, 'session_resume', arguments: _currentSession);
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

  _startTrackSession() async {
    NotificationService.init();
    try {
      String timers = "";
      final currentMinute = DateTime.now().minute;
      //TimeForSession
      switch (_prefs.lastTimeNotifications) {
        case 15:
          int firstValue = currentMinute + 15;
          if (firstValue >= 60) {
            firstValue = firstValue - 60;
          }
          int secondValue = firstValue + 15;
          if (secondValue >= 60) {
            secondValue = secondValue - 60;
          }
          int thirdValue = secondValue + 15;
          if (thirdValue >= 60) {
            thirdValue = thirdValue - 60;
          }
          int fourthValue = currentMinute;
          timers = "$firstValue,$secondValue,$thirdValue,$fourthValue";
          break;
        case 30:
          int firstValue = currentMinute + 30;
          if (firstValue >= 60) {
            firstValue = firstValue - 60;
          }
          int secondValue = currentMinute;
          timers = "$firstValue,$secondValue";
          break;
        case 45:
          int firstValue = currentMinute + 45;
          if (firstValue >= 60) {
            firstValue = firstValue - 60;
          }
          timers = "$firstValue";
          break;
        case 60:
          timers = "$currentMinute";
          break;
        default:
      }

      Map infoResponse = await sessionServices.startTrackSession(timers);
      if (infoResponse['ok']) {
        print("Start Track Session");
      } else {
        showAlertMessage(context, infoResponse['message'], () {
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

  _stopTrackSession() async {
    NotificationService.init();
    try {
      Map infoResponse = await sessionServices.stopTrackSession();
      if (infoResponse['ok']) {
        print("Stop Track Session");
      } else {
        showAlertMessage(context, infoResponse['message'], () {
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

  _clearSession() {
    _prefs.clearSession();
  }

  ////
  // MODALS
  ////
  //ShowSheets
  _showSessionSheet(double heightModal, String buttonModal, Widget sessionModal, VoidCallback callbackModal) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: BottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                  ),
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return Container(
                          height: heightModal,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 60.0,
                                padding: EdgeInsets.symmetric(horizontal: 25.0),
                                decoration: BoxDecoration(
                                  gradient: AppColor.secondaryGradient,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    TextButton(
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: AppFontSizes.buttonSize + 5.0,
                                          ),
                                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }),
                                    Expanded(child: SizedBox()),
                                    TextButton(
                                      child: Text(
                                        buttonModal,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppFontSizes.buttonSize + 5.0,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                      ),
                                      onPressed: callbackModal,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 15.0),
                              sessionModal,
                            ],
                          ),
                        );
                      },
                    );
                  },
                  onClosing: () {},
                ),
              ),
            ],
          );
        });
  }

  Widget _initNewDoseModal() {
    final size = MediaQuery.of(context).size;
    _tempConditions = [];
    _tempDose = _lastDose;
    return Container(
      height: 200.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Enter your new dose",
              style: TextStyle(
                color: AppColor.content,
                fontSize: AppFontSizes.contentSize,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 10.0),
          StatefulBuilder(
            builder: (context, setState) {
              return Container(
                  height: 100.0,
                  width: size.width,
                  child: Row(
                    children: [
                      Container(
                        height: 90,
                        margin: EdgeInsets.only(left: size.width * 0.01),
                        child: Stack(
                          children: [
                            Container(
                              width: size.width * 0.20,
                              decoration: BoxDecoration(
                                color: AppColor.content.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(size.width * 0.06),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${_currentSession!.doseMeasurement!.title}",
                                      style: TextStyle(
                                          fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.primaryColor, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      _currentSession!.doseMeasurement!.isDecimal ? _tempDose.toString() : _tempDose!.toInt().toString(),
                                      style: TextStyle(
                                        color: AppColor.content,
                                        fontSize: AppFontSizes.titleSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5.0,
                              left: 0.0,
                              child: Image(
                                color: AppColor.fifthColor,
                                width: 15.0,
                                image: AssetImage('assets/img/icon_arrow.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // color: Colors.amber,
                        height: 90,
                        width: size.width * 0.775,
                        child: Container(
                          margin: EdgeInsets.only(left: 7.5),
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
                                    AppColor.thirdColor.withAlpha(220),
                                    AppColor.primaryColor,
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
                                    _currentSession!.doseMeasurement!.isDecimal
                                        ? _currentSession!.doseMeasurement!.minScale.toString()
                                        : _currentSession!.doseMeasurement!.minScale.toInt().toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.subTitleSize,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                  Expanded(
                                    child: Center(
                                      child: _loadSliderDose(_currentSession!, setState),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                  Text(
                                    _currentSession!.doseMeasurement!.isDecimal
                                        ? _currentSession!.doseMeasurement!.maxScale.toString()
                                        : _currentSession!.doseMeasurement!.maxScale.toInt().toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.subTitleSize,
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
                  ));
            },
          ),
        ],
      ),
    );
  }

  Widget _initUpdateSymptomsModal() {
    _tempConditions = [];
    final size = MediaQuery.of(context).size;
    return Container(
      height: _valueHeightModal(_sessionConditions.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Update your rate condition(s)",
              style: TextStyle(
                color: AppColor.content,
                fontSize: AppFontSizes.contentSize,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 15.0),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _sessionConditions.length,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.001),
              itemBuilder: (BuildContext context, int index) {
                Symptom _tempSymptom;
                if (_lastRateConditions[index].length > 0) {
                  _tempSymptom = Symptom(
                      title: _sessionConditions[index].title, value: _lastRateConditions[index].last.value, tag: _sessionConditions[index].tag);
                } else {
                  _tempSymptom =
                      Symptom(title: _sessionConditions[index].title, value: _sessionConditions[index].value, tag: _sessionConditions[index].tag);
                }
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
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
                                    child: Text(
                                      _tempSymptom.title!,
                                      style: TextStyle(
                                          fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.primaryColor, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
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
                                        "${_tempSymptom.value}",
                                        style: TextStyle(fontSize: AppFontSizes.titleSize, color: AppColor.content, fontWeight: FontWeight.w700),
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
                                          fontSize: AppFontSizes.subTitleSize,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                      ),
                                      SizedBox(width: size.width * 0.01),
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
                                              value: _tempSymptom.value.toDouble(),
                                              min: 0,
                                              max: 10,
                                              divisions: 10,
                                              label: _tempSymptom.value.toString(),
                                              onChanged: (value) {
                                                setState(
                                                  () {
                                                    _tempSymptom.value = value.toInt();

                                                    // _tempConditions.add(Symptom(
                                                    //     title:
                                                    //         _tempSymptom.title,
                                                    //     value: _tempSymptom
                                                    //         .value));

                                                    final _tempSymp =
                                                        _tempConditions.where((tempSymptom) => tempSymptom.title!.contains(_tempSymptom.title!));

                                                    if (_tempSymp.length > 0) {
                                                      _tempSymp.last.value = value.toInt();
                                                    } else {
                                                      _tempConditions.add(
                                                        Condition(title: _tempSymptom.title, value: _tempSymptom.value, tag: _tempSymptom.tag),
                                                      );
                                                    }

                                                    // _tempConditions
                                                    //       .where((tempSymptom) =>
                                                    //           tempSymptom
                                                    //               .title ==
                                                    //           _tempSymptom
                                                    //               .title)
                                                    //       .last;

                                                    // _tempConditions.removeWhere(
                                                    //     (tempSymtom) =>
                                                    //         tempSymtom.title ==
                                                    //         _tempSymptom.title);

                                                    // _tempConditions.add(Symptom(
                                                    //     title:
                                                    //         _tempSymptom.title,
                                                    //     value: _tempSymptom
                                                    //         .value));
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.01),
                                      Text(
                                        '10',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: AppFontSizes.subTitleSize,
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
                      );
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _initAddNotesModal() {
    _tempConditions = [];
    _tempNote.text = "";
    return Container(
      height: 200.0,
      padding: EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              "Enter your note",
              style: TextStyle(
                color: AppColor.content,
                fontSize: AppFontSizes.contentSize,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            height: 100.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              border: Border.all(color: AppColor.content.withOpacity(0.4)),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: TextFormField(
                focusNode: FocusNode(),
                style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
                controller: _tempNote,
                minLines: 6,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Write something here...",
                  hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initAddFeelingsModal() {
    final size = MediaQuery.of(context).size;
    _tempConditions = [];
    _tempFeeling = "";
    _dataFeels.forEach((feel) {
      feel.isSelected = false;
    });
    return Container(
      height: 200.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "How do you feel",
              style: TextStyle(
                color: AppColor.content,
                fontSize: AppFontSizes.contentSize,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            height: 80.0,
            child: StatefulBuilder(
              builder: (context, setState) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _dataFeels.length,
                  itemBuilder: (BuildContext context, int index) {
                    final feel = _dataFeels[index];
                    return Stack(
                      children: [
                        InkWell(
                          child: Container(
                            width: size.width * 0.3,
                            margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                            decoration: BoxDecoration(
                              gradient: AppColor.secondaryGradient,
                              borderRadius: BorderRadius.circular(22.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0.0,
                                    right: 0.0,
                                    child: Image.network(
                                      AppLogos.iconWhiteImg,
                                      color: Colors.white.withOpacity(0.15),
                                      width: 50.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10.0,
                                    child: Container(
                                      width: size.width * 0.3,
                                      height: size.height * 0.07,
                                      child: Center(
                                        child: Text(
                                          feel.title!,
                                          style: TextStyle(
                                              color: AppColor.background,
                                              fontSize: feel.title!.length <= 9 ? AppFontSizes.contentSize + 2.0 : AppFontSizes.contentSize,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            // setState(() {
                            //   _tempFeel = index;
                            // });
                            if (feel.isSelected) {
                              setState(() {
                                feel.isSelected = false;
                                _tempFeeling = "";
                              });
                            } else {
                              setState(() {
                                feel.isSelected = true;
                                _tempFeeling = feel.title;

                                _dataFeels.forEach((feel) {
                                  if (feel.title != _tempFeeling) {
                                    feel.isSelected = false;
                                  }
                                });
                              });
                            }
                          },
                        ),
                        feel.isSelected
                            ? Positioned(
                                top: 2.5,
                                left: (size.width * 0.3) - 15.0,
                                child: Container(
                                  height: 25.0,
                                  width: 25.0,
                                  decoration: BoxDecoration(
                                    color: AppColor.secondaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: AppColor.background,
                                    size: 17.5,
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _initRateSessionModal() {
    _tempConditions = [];
    _sessionRate = 0;
    return Container(
      height: 200.0,
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              "Rate how beneficial this session was to you",
              style: TextStyle(
                color: AppColor.content,
                fontSize: AppFontSizes.contentSize,
              ),
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _rateOption("Not Good", "notgood", _sessionRate == 1 ? true : false, () {
                      setState(() {
                        _sessionRate = 1;
                      });
                    }),
                    _rateOption("Ok", "ok", _sessionRate == 2 ? true : false, () {
                      setState(() {
                        _sessionRate = 2;
                      });
                    }),
                    _rateOption("Good", "good", _sessionRate == 3 ? true : false, () {
                      setState(() {
                        _sessionRate = 3;
                      });
                    }),
                    _rateOption("Great", "great", _sessionRate == 4 ? true : false, () {
                      setState(() {
                        _sessionRate = 4;
                      });
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  ////
  //CUSTOMS
  ////
  String showSessionTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_durationSession.inHours.remainder(60));
    final minutes = twoDigits(_durationSession.inMinutes.remainder(60));
    final seconds = twoDigits(_durationSession.inSeconds.remainder(60));
    if (_durationSession.inMinutes >= 60) {
      return '$hours:$minutes';
    } else {
      return '$minutes:$seconds';
    }
  }

  String showSessionTimeline(DateTime time) {
    final timer = time.difference(_currentSession!.sessionStartTime!).inSeconds;
    final timing = DateTime(0, 0, 0, 0, 0, timer);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(timing.hour.remainder(60));
    final minutes = twoDigits(timing.minute.remainder(60));
    final seconds = twoDigits(timing.second.remainder(60));
    if (timer >= 3600) {
      return '$hours:$minutes';
    } else {
      return '$minutes:$seconds';
    }
  }

  double _valueHeightSheet(int conditions) {
    if (conditions <= 1) {
      return 300.0;
    } else if (conditions <= 2) {
      return 200.0 * conditions;
    } else if (conditions <= 3) {
      return 170.0 * conditions;
    } else {
      return 150.0 * conditions;
    }
  }

  double _valueHeightModal(int conditions) {
    if (conditions <= 1) {
      return 200.0;
    } else if (conditions <= 2) {
      return 150.0 * conditions;
    } else if (conditions <= 3) {
      return 125.0 * conditions;
    } else {
      return 120.0 * conditions;
    }
  }

  SliderTheme _loadSliderDose(Session currentSession, void Function(void Function()) setState) {
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
        thumbColor: AppColor.content,
        overlayColor: Colors.white.withOpacity(.4),
        activeTickMarkColor: Colors.white,
        inactiveTickMarkColor: Colors.white.withOpacity(0.5),
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: AppColor.thirdColor,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
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
            },
          );
        },
      ),
    );
  }

  String _setDosesPosition(int? position) {
    switch (position) {
      case 1:
        return "1st";
      case 2:
        return "2nd";
      case 3:
        return "3rd";
      case 4:
        return "4th";
      default:
        return "${position.toString()}th";
    }
  }

  Widget _rateOption(String title, String image, bool isSelect, VoidCallback callback) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: AppColor.fifthColor.withOpacity(0.5),
      borderRadius: BorderRadius.all(Radius.circular(50.0)),
      child: Container(
        height: 90.0,
        width: 70.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              height: 50.0,
              width: 50.0,
              image: AssetImage('assets/img/icon_feel_$image.png'),
              color: isSelect ? AppColor.secondaryColor : AppColor.content.withOpacity(0.7),
              fit: BoxFit.contain,
            ),
            SizedBox(height: 5.0),
            Container(
              width: 60.0,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSizes.contentSize - 2.5,
                  color: isSelect ? AppColor.secondaryColor : AppColor.content,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      onTap: callback,
    );
  }

  String _setDurationParamenter(DateTime time) {
    if (time.hour >= 1) {
      return "h";
    } else if (time.minute >= 1) {
      return "m";
    } else {
      return "s";
    }
  }

  double _valueUpdateHeightTimeLine() {
    final size = MediaQuery.of(context).size;
    if (_tempConditions.length > 0) {
      return (size.height * 0.09) * _tempConditions.length;
    } else {
      return size.height * 0.09;
    }
  }

  void _updatePositionTimeLine() {
    double _update = 0.0;
    _sessionTimeLines.length > 4 ? _update = _valueUpdateHeightTimeLine() : _update = 0.0;
    _timeLineController!.animateTo(_timeLineController!.position.maxScrollExtent + _update, duration: Duration(seconds: 1), curve: Curves.ease);
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 4, startY = 0;
    final paint = Paint()
      ..color = AppColor.content.withOpacity(0.5)
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

//SETUP NOTIFICATIONS DIALOG
void showSetupNotificationTimingDialog(BuildContext context, int lastTimeNotification, VoidCallback callback) {
  final _prefs = new UserPreference();
  final List<int> dataNotificationTimes = AppData.dataNotificationTimes;
  //TimeForSession
  if (lastTimeNotification > 0) {
    _prefs.lastTimeNotifications = lastTimeNotification;
  } else {
    _prefs.lastTimeNotifications = 15;
  }
  showSetupTimerDialog(
      context,
      "Track your symptoms",
      200.0,
      Container(
        height: 200.0,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: RichText(
                text: new TextSpan(
                  style: new TextStyle(
                    fontSize: AppFontSizes.contentSize + 0.5,
                    color: AppColor.content,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: 'We will send you a reminder every '),
                    new TextSpan(text: "${_prefs.timeNotifications.toString()} minutes", style: new TextStyle(fontWeight: FontWeight.w800)),
                    new TextSpan(text: ' during your session to update your symptoms.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 150.0,
                  height: 80.0,
                  child: Text(
                    "You can change the timing of these reminders using the options to the right.",
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize + 0.5,
                      color: AppColor.content,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 20.0),
                Container(
                  width: 70.0,
                  height: 70.0,
                  decoration: BoxDecoration(
                    color: AppColor.content.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    ),
                  ),
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 25.0,
                    useMagnifier: true,
                    magnification: 1.2,
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
                      //TimeForSession
                      _prefs.lastTimeNotifications = dataNotificationTimes[index],
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  height: 70.0,
                  width: 30.0,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          color: AppColor.background,
                          width: 20.0,
                          image: AssetImage('assets/img/icon_arrowUp.png'),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 20.0),
                        Image(
                          color: AppColor.background,
                          width: 20.0,
                          image: AssetImage('assets/img/icon_arrowDown.png'),
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      callback);
}

void showSetupTimerDialog(BuildContext context, String title, double height, Widget content, VoidCallback callback) {
  Dialog fancyDialog = Dialog(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Container(
      height: 150.0 + height,
      width: 300.0,
      child: Stack(
        children: <Widget>[
          //TOP
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 60.0,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: AppColor.secondaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                  ),
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ),
          ),
          //CENTER
          Align(
            alignment: Alignment.center,
            child: content,
          ),
          //BOTTOM
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColor.background,
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
                        "Start",
                        style: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w600),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: callback,
            ),
          ),
        ],
      ),
    ),
  );
  showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => fancyDialog);
}
