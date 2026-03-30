import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/models/canna_feel_model.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/models/session_timeline_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSession/card_session_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSmall/cardSmall_species_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSmall/cardSmall_conditions_widget.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/cardSmall/cardsmall_product_type_widget.dart';

import '../../services/session/session_service.dart';

class SessionResumePage extends StatefulWidget {
  @override
  _SessionResumePageState createState() => _SessionResumePageState();
}

class _SessionResumePageState extends State<SessionResumePage> {
  final _prefs = new UserPreference();
  final sessionServices = SessionServices();
  Session? _currentSession;
  List<SessionTimeLine> _timelineFeels = [];
  List<SessionTimeLine> _timelineNotes = [];
  List<String?> _additionalNotes = [];

  bool _addAdditionalNote = false;
  TextEditingController _additionalNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      _loadSessionFeels();
      _loadSessionNotes();
      _loadAdditionalNotes();
      if (_prefs.expiredTimeCurrentSession) {
        showAlertMessage(context, "Your session has expired (24hrs) limit time.", () {
          Navigator.pop(context);
          _prefs.expiredTimeCurrentSession = false;
        });
      }
    }();
  }

  String showSessionTimeDuration() {
    // final timer = _currentSession.sessionEndTime
    //     .difference(_currentSession.sessionStartTime)
    //     .inSeconds;
    // final timing = DateTime(0, 0, 0, 0, 0, timer);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_currentSession!.sessionDurationTime!.hour.remainder(60));
    final minutes = twoDigits(_currentSession!.sessionDurationTime!.minute.remainder(60));
    final seconds = twoDigits(_currentSession!.sessionDurationTime!.second.remainder(60));
    switch (_currentSession!.sessionDurationParameter) {
      case "h":
        return '$hours:$minutes hr';

      case "m":
        return '$minutes:$seconds min';

      case "s":
        return '$seconds sec';

      default:
        return '$hours:$minutes:$seconds';
    }
  }

  String showSessionTime(DateTime time) {
    final timer = time.difference(_currentSession!.sessionStartTime!).inSeconds;
    final timing = DateTime(0, 0, 0, 0, 0, timer);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(timing.hour.remainder(60));
    final minutes = twoDigits(timing.minute.remainder(60));
    final seconds = twoDigits(timing.second.remainder(60));
    switch (_currentSession!.sessionDurationParameter) {
      case "h":
        return '$hours:$minutes hr';

      case "m":
        return '$minutes:$seconds min';

      case "s":
        return '$seconds sec';

      default:
        return '$hours:$minutes:$seconds';
    }
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
          leading: _currentSession!.sessionStatus == 'stored'
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColor.content,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : Container(),
          actions: <Widget>[
            _currentSession!.sessionStatus == 'stored'
                ? InkWell(
                    child: Container(
                      width: 80.0,
                      padding: EdgeInsets.only(left: 5.0, right: 10.0),
                      child: Center(
                        child: Text(
                          "Recreate Session",
                          style: TextStyle(
                            fontSize: AppFontSizes.buttonSize + (size.width * 0.00025),
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: () {
                      print("> Recreate Session");
                      if (_prefs.demoVersion) {
                        showAlertMessage(context, 'Not available in demo version', () {
                          Navigator.pop(context);
                        });
                      } else {
                        setState(() {
                          Navigator.pushNamed(context, 'session_start', arguments: _currentSession);
                        });
                      }
                    },
                  )
                : InkWell(
                    child: Container(
                      width: 80.0,
                      padding: EdgeInsets.only(left: 5.0, right: 15.0),
                      child: Center(
                        child: Text(
                          "Done",
                          style: TextStyle(
                            fontSize: AppFontSizes.buttonSize + 5.0,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: () {
                      print("> Done");
                      setState(() {
                        Navigator.pushReplacementNamed(context, 'navigation');
                      });
                    },
                  ),
          ],
        ),
      ),
      body: Container(
        height: size.height,
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
                    "Session Summary",
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
                  left: size.width * 0.07,
                  right: size.width * 0.07,
                ),
                child: _sessionDataCard(context),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.01,
                  left: size.width * 0.07,
                  right: size.width * 0.07,
                ),
                child: _sessionChartCard(context),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.01,
                  left: size.width * 0.07,
                  right: size.width * 0.07,
                ),
                child: _sessionAdditionalNotesCard(context),
              ),
              SizedBox(height: size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  //Session Data Card
  Widget _sessionDataCard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Container(
        decoration: BoxDecoration(color: AppColor.content.withOpacity(0.2), borderRadius: BorderRadius.circular(size.width * 0.05)),
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                height: size.width * 0.55,
                child: _resumeTimeCard(context),
              ),
            ),
            Flexible(
              flex: 2,
              child: InkWell(
                child: Container(
                  height: size.width * 0.55,
                  child: _resumeSessionCard(context),
                ),
                onTap: () {
                  print("Show Card Cannabis");
                  showCardSession(context, _currentSession);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Resume Time Card
  Widget _resumeTimeCard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: size.width * 0.03,
            left: size.width * 0.03,
            right: size.width * 0.02,
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: size.height * 0.003),
                child: Text(
                  "Session Date",
                  style: TextStyle(
                    fontSize: size.width * 0.032,
                    color: AppColor.content,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: 40.0,
                child: Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      decoration: BoxDecoration(
                        color: AppColor.content.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(size.width * 0.035),
                      ),
                      child: Center(
                        child: Text(
                          '${_currentSession!.sessionStartTime!.month.toString()}/${_currentSession!.sessionStartTime!.day.toString()}/${_currentSession!.sessionStartTime!.year.toString()}',
                          style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2.5,
                      child: Image(
                        color: AppColor.fifthColor,
                        width: 12.0,
                        image: AssetImage('assets/img/icon_arrow.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.003,
            left: size.width * 0.04,
            right: size.width * 0.02,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(bottom: size.height * 0.003),
                      child: Text(
                        "Start Time",
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          color: AppColor.content,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 45,
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 2.5),
                            decoration:
                                BoxDecoration(color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(size.width * 0.035)),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    DateFormat.jm().format(_currentSession!.sessionStartTime!.toLocal()),
                                    style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2.5,
                            left: 0.0,
                            child: Image(
                              color: AppColor.fifthColor,
                              width: 12.0,
                              image: AssetImage('assets/img/icon_arrow.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(bottom: size.height * 0.003),
                      child: Text(
                        "End Time",
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          color: AppColor.content,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 45,
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 2.5),
                            decoration:
                                BoxDecoration(color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(size.width * 0.035)),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    DateFormat.jm().format(_currentSession!.sessionEndTime!.toLocal()),
                                    style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2.5,
                            left: 2.5,
                            child: Image(
                              color: AppColor.fifthColor,
                              width: 12.0,
                              image: AssetImage('assets/img/icon_arrow.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.003,
            left: size.width * 0.04,
            right: size.width * 0.02,
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: size.height * 0.003),
                child: Text(
                  "Session Time",
                  style: TextStyle(
                    fontSize: size.width * 0.032,
                    color: AppColor.content,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 40.0,
                child: Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      decoration: BoxDecoration(
                        color: AppColor.background,
                        borderRadius: BorderRadius.circular(size.width * 0.035),
                      ),
                      child: Center(
                        child: Text(
                          showSessionTimeDuration(),
                          style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize + 4.0, fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2.5,
                      left: 0.0,
                      child: Image(
                        color: AppColor.fifthColor,
                        width: 12.0,
                        image: AssetImage('assets/img/icon_arrow.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //Resume Session Card
  Widget _resumeSessionCard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: size.width * 0.03,
        left: size.width * 0.02,
        right: size.width * 0.03,
      ),
      child: Column(
        children: [
          conditionsCardSmall(size, [..._currentSession!.primaryCondition!, ..._currentSession!.secondaryCondition!], false),
          productTypeCardSmall(size, _currentSession!.productType!, false),
          speciesCardSmall(size, _currentSession!.strainType, false),
        ],
      ),
    );
  }

  //Session Chart Card
  Widget _sessionChartCard(BuildContext context) {
    var allConditions = [..._currentSession!.primaryCondition!, ..._currentSession!.secondaryCondition!];
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Container(
        decoration: BoxDecoration(color: AppColor.content.withOpacity(0.2), borderRadius: BorderRadius.circular(size.width * 0.05)),
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.02,
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                  bottom: size.height * 0.02,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Session Doses",
                              style: TextStyle(
                                fontSize: AppFontSizes.contentSize - 1.0,
                                color: AppColor.content,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Container(
                            alignment: Alignment.center,
                            height: size.width * 0.1,
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 10.0),
                                  decoration: BoxDecoration(
                                      color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(size.width * 0.035)),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          _numberSessionDoses(),
                                          style: TextStyle(
                                              color: AppColor.content, fontSize: AppFontSizes.contentSize + 4.0, fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 2.5,
                                  left: 0.0,
                                  child: Image(
                                    color: AppColor.fifthColor,
                                    width: 12.0,
                                    image: AssetImage('assets/img/icon_arrow.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(bottom: 5.0, left: 10.0),
                            child: Text(
                              "Session Rating",
                              style: TextStyle(
                                fontSize: AppFontSizes.contentSize - 1.0,
                                color: AppColor.content,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Container(
                            alignment: Alignment.center,
                            height: size.width * 0.1,
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  decoration: BoxDecoration(
                                      color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(size.width * 0.035)),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Image(
                                          color: AppColor.secondaryColor,
                                          width: 30.0,
                                          image: AssetImage('assets/img/${_loadImageRate(_currentSession!.sessionRate)}'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 2.5,
                                  left: 10.0,
                                  child: Image(
                                    color: AppColor.fifthColor,
                                    width: 12.0,
                                    image: AssetImage('assets/img/icon_arrow.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.width * 0.005),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
              child: Text(
                "Condition(s) Treated",
                style: TextStyle(
                  fontSize: AppFontSizes.contentSize - 1.0,
                  fontWeight: FontWeight.w500,
                  color: AppColor.content,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Container(
              alignment: Alignment.center,
              height: 50.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: allConditions.length,
                itemBuilder: (BuildContext context, int index) {
                  final condition = allConditions[index];
                  return InkWell(
                    child: Container(
                      width: size.width * _widthSymptomChars(),
                      decoration: BoxDecoration(
                        color: condition.isSelected ? AppColor.secondaryColor : AppColor.content.withOpacity(0.1),
                        borderRadius: allConditions.length > 1 ? _initBorderMeasurement(index) : BorderRadius.circular(15.0),
                        border: Border.all(color: AppColor.content.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(
                          condition.title!,
                          style: TextStyle(
                              color: condition.isSelected ? Colors.white : AppColor.content,
                              fontSize: AppFontSizes.contentSize,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (condition.isSelected) {
                          condition.isSelected = false;
                        } else {
                          condition.isSelected = true;
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Container(
              height: size.height * 0.35,
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0, right: 25.0, left: 15.0),
              child: LineChart(
                LineChartData(
                    lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (value) {
                        return value
                            .map((e) => LineTooltipItem(
                                  "Rate: ${e.y.toInt()} Time: ${e.x.toInt()} ${_currentSession!.sessionDurationParameter}",
                                  // "${e.y < 0 ? 'Rate:' : 'Income:'} ${e.y.toStringAsFixed(2)} \n Diff: ",
                                  TextStyle(
                                      color: AppColor.background.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppFontSizes.contentSmallSize),
                                ))
                            .toList();
                      },
                      tooltipBgColor: AppColor.primaryColor,
                    )),
                    minX: 0,
                    maxX: _timeValueChartDuration(),
                    minY: 0,
                    maxY: 9,
                    backgroundColor: AppColor.background,
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 15.0,
                          // margin: 12.0,
                          // getTextStyles: (context, value) =>
                          //     TextStyle(color: AppColor.content.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: AppFontSizes.contentSmallSize),
                          // getTitles: (value) {
                          //   return '${value.toInt()}';
                          // },
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              // margin: 6.0,
                              reservedSize: 20.0,
                              // getTextStyles: (context, value) => TextStyle(
                              //     color: AppColor.content.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: AppFontSizes.contentSmallSize),
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  // case 0:
                                  //   return '2016';
                                  // case 1:
                                  //   return '2017';
                                  default:
                                    return Text('${value.toInt()}${_currentSession!.sessionDurationParameter}');
                                }
                              })),
                    ),
                    //                axisTitleData: FlAxisTitleData(
                    // leftTitle: AxisTitle(
                    //     showTitle: true,
                    //     titleText: 'Condition Severity',
                    //     textStyle: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.secondaryColor),
                    //     margin: 7.0,
                    //     textAlign: TextAlign.left),
                    // bottomTitle: AxisTitle(
                    //     showTitle: true,
                    //     margin: 5.0,
                    //     titleText: 'Dose Administered',
                    //     textStyle: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.primaryColor),
                    //     textAlign: TextAlign.left)),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColor.content.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: AppColor.content.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: AppColor.content.withOpacity(0.3),
                          width: 2,
                        )),
                    lineBarsData: _loadSymptomsPoints()),
              ),
            ),
            SizedBox(height: size.height * 0.005),
            _timelineFeels.length > 0
                ? Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20.0, top: 5.0),
                        child: Text(
                          "Session Feelings",
                          style: TextStyle(
                            fontSize: AppFontSizes.contentSize - 1.0,
                            fontWeight: FontWeight.w500,
                            color: AppColor.content,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.005),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.005,
                          horizontal: size.width * 0.025,
                        ),
                        child: Container(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _timelineFeels.length,
                            itemBuilder: (BuildContext context, int index) {
                              final feel = Feel(title: _timelineFeels[index].title);
                              return Container(
                                height: size.height * 0.05,
                                margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: 5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: size.height * 0.05,
                                          width: size.width * 0.2,
                                          child: Row(
                                            children: [
                                              Image(
                                                color: AppColor.fifthColor,
                                                width: 12.0,
                                                image: AssetImage('assets/img/icon_arrow.png'),
                                                fit: BoxFit.contain,
                                              ),
                                              SizedBox(width: 5.0),
                                              Container(
                                                child: Center(
                                                  child: Text(
                                                    showSessionTime(_timelineFeels[index].time!),
                                                    style: TextStyle(
                                                      color: AppColor.content,
                                                      fontSize: AppFontSizes.contentSmallSize + 1.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Flexible(
                                          child: Container(
                                            height: size.height * 0.05,
                                            decoration: BoxDecoration(
                                                color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(size.width * 0.035)),
                                            child: Center(
                                              child: Text(
                                                feel.title!,
                                                style: TextStyle(
                                                    color: AppColor.content, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w800),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(height: size.height * 0.01),
            _timelineNotes.length > 0
                ? Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20.0, top: 0.0),
                        child: Text(
                          "Session Notes",
                          style: TextStyle(
                            fontSize: AppFontSizes.contentSize - 1.0,
                            fontWeight: FontWeight.w500,
                            color: AppColor.content,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.005),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.005,
                          horizontal: size.width * 0.025,
                        ),
                        child: Container(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _timelineNotes.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: size.height * 0.05 + (_timelineNotes[index].title!.length * 0.5),
                                margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: 5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: size.height * 0.05,
                                          width: size.width * 0.2,
                                          child: Row(
                                            children: [
                                              Image(
                                                color: AppColor.fifthColor,
                                                width: 12.0,
                                                image: AssetImage('assets/img/icon_arrow.png'),
                                                fit: BoxFit.contain,
                                              ),
                                              SizedBox(width: 5.0),
                                              Container(
                                                child: Center(
                                                  child: Text(
                                                    showSessionTime(_timelineNotes[index].time!),
                                                    style: TextStyle(
                                                      color: AppColor.content,
                                                      fontSize: AppFontSizes.contentSmallSize + 1.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Flexible(
                                          child: Container(
                                            height: size.height * 0.05 + (_timelineNotes[index].title!.length * 0.5),
                                            decoration: BoxDecoration(
                                                color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(size.width * 0.035)),
                                            child: Center(
                                              child: Text(
                                                _timelineNotes[index].title!,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSmallSize + 0.5),
                                                textAlign: TextAlign.center,
                                                maxLines: 4,
                                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(height: size.height * 0.01),
          ],
        ),
      ),
    );
  }

  //Session Additional Notes Card
  Widget _sessionAdditionalNotesCard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Container(
        decoration: BoxDecoration(color: AppColor.content.withOpacity(0.2), borderRadius: BorderRadius.circular(size.width * 0.05)),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 5.0),
              child: Text(
                "Additonal Notes",
                style: TextStyle(
                  fontSize: AppFontSizes.contentSize - 1.0,
                  color: AppColor.content,
                ),
              ),
            ),
            _additionalNotes.length > 0
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.005,
                      horizontal: size.width * 0.025,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _additionalNotes.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: [
                            Container(
                              height: size.height * 0.05 + (_additionalNotes[index]!.length * 0.5),
                              margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: size.width * 0.01),
                              decoration:
                                  BoxDecoration(color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(size.width * 0.035)),
                              child: Center(
                                child: Text(
                                  _additionalNotes[index]!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSmallSize + 0.5),
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 7.5,
                              left: 2.5,
                              child: Image(
                                color: AppColor.fifthColor,
                                width: 12.0,
                                image: AssetImage('assets/img/icon_arrow.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : SizedBox(height: size.height * 0.01),
            _initAdditionalNotes(context),
          ],
        ),
      ),
    );
  }

  Widget _initAdditionalNotes(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      child: Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.01,
          left: size.width * 0.05,
          right: size.width * 0.05,
          bottom: size.height * 0.02,
        ),
        child: Column(children: [
          _addAdditionalNote
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
                          "New Note",
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
                          controller: _additionalNoteController,
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
              : Container(),
          _addAdditionalNote
              ? Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Material(
                    elevation: 2.0,
                    shadowColor: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(size.width * 0.025),
                    child: InkWell(
                      child: Container(
                        height: 60.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(size.width * 0.025),
                          ),
                          gradient: AppColor.thirdGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            children: [
                              Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: AppFontSizes.buttonSize + 5.0,
                                  color: AppColor.background,
                                  fontWeight: FontWeight.w700,
                                ),
                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        print("SAVE NOTES");
                        var textNote = _additionalNoteController.text.trim();
                        if (textNote.isNotEmpty) {
                          _addNoteSession(context, _additionalNoteController.text);
                          setState(() {
                            _addAdditionalNote ? _addAdditionalNote = false : _addAdditionalNote = true;
                          });
                        }
                      },
                    ),
                  ),
                )
              : Material(
                  elevation: 2.0,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(size.width * 0.025),
                  child: InkWell(
                    child: Container(
                      height: 60.0,
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
                        child: Stack(
                          children: [
                            Positioned(
                              top: 7.5,
                              left: size.width * 0.02,
                              child: Text(
                                "Add Notes",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.1),
                                  fontSize: AppFontSizes.buttonSize + 7.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20.0,
                              left: size.width * 0.02,
                              child: Text(
                                "Add Notes",
                                style: TextStyle(
                                  fontSize: AppFontSizes.buttonSize + 2.5,
                                  color: AppColor.background,
                                  fontWeight: FontWeight.w700,
                                ),
                                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                              ),
                            ),
                            Positioned(
                              top: 9.0,
                              right: size.width * 0.01,
                              child: Icon(
                                Icons.add,
                                size: 40.0,
                                color: AppColor.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      if (_prefs.demoVersion) {
                        showAlertMessage(context, 'Not available in demo version', () {
                          Navigator.pop(context);
                        });
                      } else {
                        setState(() {
                          _addAdditionalNote ? _addAdditionalNote = false : _addAdditionalNote = true;
                        });
                      }
                    },
                  ),
                ),
        ]),
      ),
    );
  }

  List<LineChartBarData> _loadSymptomsPoints() {
    List<LineChartBarData> tempTimeLineCharts = [];

    [...?_currentSession!.primaryCondition, ...?_currentSession!.secondaryCondition].forEach((symptom) {
      List<FlSpot> _tempTimelineSymptomPoints = [];
      List<FlSpot> _tempTimelineDosesPoints = [];
      _currentSession!.sessionTimeLines!.forEach((timeline) {
        if (timeline.type == "condition") {
          if (timeline.title == symptom.title) {
            _tempTimelineSymptomPoints.add(FlSpot(_timeValueChart(timeline.time!.toLocal()), timeline.rate.toDouble()));
            print("> Symptom:${FlSpot(_timeValueChart(timeline.time!), timeline.rate.toDouble())}");
          }
        } else if (timeline.type == "dose") {
          _tempTimelineDosesPoints.add(FlSpot(_timeValueChart(timeline.time!.toLocal()), 0));
          print("> Dose:${FlSpot(_timeValueChart(timeline.time!), timeline.rate.toDouble())}");
        }
      });
      tempTimeLineCharts.add(
        LineChartBarData(
            spots: _tempTimelineSymptomPoints,
            isCurved: false,
            gradient: symptom.isSelected
                ? LinearGradient(colors: AppColor.gradientList)
                : LinearGradient(colors: [AppColor.content.withAlpha(90), AppColor.content.withAlpha(60)]),
            barWidth: 7.0,
            belowBarData: BarAreaData(
              show: true,
              gradient: symptom.isSelected
                  ? LinearGradient(colors: AppColor.gradientList.map((color) => color.withOpacity(0.4)).toList())
                  : LinearGradient(
                      colors: [AppColor.content.withOpacity(0.5), AppColor.content.withOpacity(0.1)].map((color) => color.withOpacity(0.2)).toList()),
            )),
      );
      tempTimeLineCharts.add(
        LineChartBarData(
          spots: _tempTimelineDosesPoints,
          gradient: LinearGradient(colors: [AppColor.fifthColor, AppColor.secondaryColor]),
          barWidth: 7.0,
        ),
      );
    });

    return tempTimeLineCharts;
  }

  double _timeValueChartDuration() {
    final timer = _currentSession!.sessionEndTime!.difference(_currentSession!.sessionStartTime!).inSeconds;
    final timing = DateTime(0, 0, 0, 0, 0, timer);
    switch (_currentSession!.sessionDurationParameter) {
      case "h":
        if (timing.hour >= 1) {
          return timing.hour.toDouble();
        } else if (timing.minute >= 1) {
          return timing.minute.toDouble() / 60;
        } else {
          return timing.second.toDouble() / 3600;
        }

      case "m":
        if (timing.minute >= 1) {
          return timing.minute.toDouble();
        } else {
          return timing.second.toDouble() / 60;
        }

      case "s":
        return timing.second.toDouble();

      default:
        return timing.second.toDouble();
    }
  }

  double _timeValueChart(DateTime time) {
    print(time.toIso8601String());
    final timer = time.difference(_currentSession!.sessionStartTime!).inSeconds;
    final timing = DateTime(0, 0, 0, 0, 0, timer);
    switch (_currentSession!.sessionDurationParameter) {
      case "h":
        if (timing.hour >= 1) {
          return timing.hour.toDouble();
        } else if (timing.minute >= 1) {
          return timing.minute.toDouble() / 60;
        } else {
          return timing.second.toDouble() / 3600;
        }

      case "m":
        if (timing.minute >= 1) {
          return timing.minute.toDouble();
        } else {
          return timing.second.toDouble() / 60;
        }

      case "s":
        return timing.second.toDouble();

      default:
        return timing.second.toDouble();
    }
  }

  String _numberSessionDoses() {
    int dosesCount = 0;
    _currentSession!.sessionTimeLines!.forEach((timeline) {
      if (timeline.type == "dose") {
        dosesCount += 1;
      }
    });
    return "x$dosesCount";
  }

  String _loadImageRate(int rate) {
    switch (rate) {
      case 4:
        return "icon_feel_great.png";

      case 3:
        return "icon_feel_good.png";

      case 2:
        return "icon_feel_ok.png";

      default:
        return "icon_feel_notgood.png";
    }
  }

  double _widthSymptomChars() {
    return 0.72 / [...?_currentSession!.primaryCondition, ...?_currentSession!.secondaryCondition].length;
  }

  BorderRadiusGeometry _initBorderMeasurement(int index) {
    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(15.0),
        bottomLeft: Radius.circular(15.0),
      );
    } else if ([...?_currentSession!.primaryCondition, ...?_currentSession!.secondaryCondition].length - 1 == index) {
      return BorderRadius.only(
        topRight: Radius.circular(15.0),
        bottomRight: Radius.circular(15.0),
      );
    } else {
      return BorderRadius.circular(0.0);
    }
  }

  void _loadSessionFeels() {
    _currentSession!.sessionTimeLines!.forEach((timeline) {
      if (timeline.type == "feeling") {
        _timelineFeels.add(timeline);
      }
    });
    setState(() {});
  }

  void _loadSessionNotes() {
    _currentSession!.sessionTimeLines!.forEach((timeline) {
      if (timeline.type == "note") {
        _timelineNotes.add(timeline);
      }
    });
    setState(() {});
  }

  void _loadAdditionalNotes() {
    _additionalNotes = [];
    if (_currentSession!.sessionNote != '') {
      _additionalNotes.add(_currentSession!.sessionNote);
    }
    _currentSession!.sessionAdditionalNotes!.forEach((note) {
      _additionalNotes.add(note);
    });
    setState(() {});
  }

  _addNoteSession(BuildContext context, String note) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse = await sessionServices.addNoteSessionbyId(_currentSession!.sessionId, note);
      if (infoResponse['ok']) {
        _additionalNoteController.text = '';
        _currentSession = infoResponse['session'];
        _loadAdditionalNotes();
        setState(() {});
        progressDialog.dismiss();
      } else {
        progressDialog.dismiss();
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
