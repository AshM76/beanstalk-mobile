import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/pages/history/history_page.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/session/session_service.dart';
import 'package:beanstalk_mobile/src/services/user/user_profile_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';

import '../../services/demo/demo_service.dart';

class JournalPage extends StatefulWidget {
  JournalPage({Key? key}) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _userProfileServices = UserProfileServices();
  final _sessionServices = SessionServices();
  final _prefs = new UserPreference();

  List<Session>? _userSessions = [];

  @override
  void initState() {
    super.initState();
    print(":: Session Active => ${_prefs.activeSession}");
    if (_prefs.activeSession) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed("session_active");
      });
    }
    () async {
      await Future.delayed(Duration.zero);
      loadProfileData(context);
    }();
  }

  String showSessionTimeDuration(Session session) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(session.sessionDurationTime!.hour.remainder(60));
    final minutes = twoDigits(session.sessionDurationTime!.minute.remainder(60));
    final seconds = twoDigits(session.sessionDurationTime!.second.remainder(60));
    switch (session.sessionDurationParameter) {
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

    return Container(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.066),
          child: AppBar(
            scrolledUnderElevation: 0.0,
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
          ),
        ),
        body: Container(
            width: size.width,
            color: AppColor.background,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Journal",
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                        fontFamily: AppFont.primaryFont,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Container(
                  height: size.height * 0.68,
                  child: SingleChildScrollView(
                    child: StaggeredGrid.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children: [
                        StaggeredGridTile.extent(crossAxisCellCount: 2, mainAxisExtent: 20.0, child: _initTitleSection("Last Session")),
                        StaggeredGridTile.extent(
                            crossAxisCellCount: 1,
                            mainAxisExtent: 150.0,
                            child: InkWell(
                              child: _initNewSessionSection(),
                              onTap: () {
                                Navigator.pushNamed(context, 'session_setup').then((_) => setState(() {}));
                              },
                            )),
                        StaggeredGridTile.extent(
                            crossAxisCellCount: 2,
                            mainAxisExtent: 120.0,
                            child: InkWell(
                              child: _initLastSessionSection(),
                              onTap: () {
                                if (_userSessions!.length > 0) {
                                  loadSessionData(context, _userSessions!.first.sessionId);
                                }
                              },
                            )),
                        StaggeredGridTile.extent(crossAxisCellCount: 3, mainAxisExtent: 2.5, child: _initSpaceSection()),
                        StaggeredGridTile.extent(crossAxisCellCount: 1, mainAxisExtent: 20.0, child: _initTitleSection("History")),
                        StaggeredGridTile.extent(crossAxisCellCount: 2, mainAxisExtent: 20.0, child: _initTitleSection("Recent Sessions")),
                        StaggeredGridTile.extent(
                            crossAxisCellCount: 1,
                            mainAxisExtent: 120.0,
                            child: InkWell(
                              child: _initHistorySection(),
                              onTap: () {
                                loadSessionsData(context);
                              },
                            )),
                        StaggeredGridTile.extent(crossAxisCellCount: 2, mainAxisExtent: 120.0, child: _initRecentSessions()),
                        StaggeredGridTile.extent(crossAxisCellCount: 3, mainAxisExtent: 20.0, child: Container()),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _initSpaceSection() {
    return Container();
  }

  Widget _initTitleSection(String title) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(
            color: AppColor.fifthColor,
            height: 15.0,
            width: 15.0,
            image: AssetImage('assets/img/icon_arrow.png'),
            fit: BoxFit.contain,
          ),
          SizedBox(width: 5.0),
          Text(
            title,
            style: TextStyle(height: 1.1, fontSize: AppFontSizes.subTitleSize, fontFamily: AppFont.primaryFont, color: AppColor.content),
            textScaler: TextScaler.linear(AppFontScales.adaptiveScale - 0.1),
          ),
        ],
      ),
    );
  }

  Widget _initNewSessionSection() {
    final size = MediaQuery.of(context).size;
    return Material(
      elevation: 2.5,
      borderRadius: BorderRadius.circular(size.width * 0.05),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.05),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * 0.05),
                  color: AppColor.secondaryColor,
                ),
              ),
              Positioned(
                right: size.width * 0.03,
                top: size.width * 0.03,
                child: Image(
                  height: size.width * 0.05,
                  width: size.width * 0.05,
                  image: AssetImage('assets/img/icon_plus.png'),
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: 30.0,
                child: Image(
                  height: 75.0,
                  width: 75.0,
                  image: AssetImage('assets/img/icon_session.png'),
                  color: Colors.white,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(size.width * 0.05),
                      bottomLeft: Radius.circular(size.width * 0.05),
                    ),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  height: 32.5,
                  width: size.width * 0.3,
                ),
              ),
              Positioned(
                bottom: 2.5,
                child: Text(
                  'New',
                  style: TextStyle(
                      fontFamily: AppFont.primaryFont, fontSize: AppFontSizes.subTitleSize + 5.0, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          )),
    );
  }

  Widget _initLastSessionSection() {
    final size = MediaQuery.of(context).size;
    if (_userSessions!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.05),
          color: AppColor.content.withOpacity(0.05),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Once you've logged a session, you'll see a summary here",
              style: TextStyle(
                fontSize: AppFontSizes.contentSize - 1.0,
                color: AppColor.content.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else {
      return Material(
        elevation: 2.5,
        borderRadius: BorderRadius.circular(size.width * 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.05),
            color: AppColor.content.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  child: _resumeSessionCard(context, _userSessions!.first),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  child: _resumeTimeCard(context, _userSessions!.first),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _initHistorySection() {
    final size = MediaQuery.of(context).size;
    return Material(
      elevation: 2.5,
      borderRadius: BorderRadius.circular(size.width * 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.05),
          color: AppColor.content.withOpacity(0.05),
        ),
        child: Stack(
          children: [
            Center(
              child: Image(
                width: size.width * 0.17,
                height: size.height * 0.17,
                image: AssetImage('assets/img/icon_calendar.png'),
                color: AppColor.primaryColor,
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: size.height * 0.02),
                child: Text(
                  DateFormat('dd').format(DateTime.now()).toString(),
                  style: TextStyle(fontSize: size.width * 0.1, color: AppColor.primaryColor, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initRecentSessions() {
    final size = MediaQuery.of(context).size;
    if (_userSessions!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.05),
          color: AppColor.content.withOpacity(0.05),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Once you log sessions, your most recent sessions will appear here",
              style: TextStyle(
                fontSize: AppFontSizes.contentSize - 1.0,
                color: AppColor.content.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.05),
          color: AppColor.content.withOpacity(0.05),
        ),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _userSessions!.length,
            itemBuilder: (BuildContext context, int index) {
              final session = _userSessions![index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: size.width * 0.008),
                child: InkWell(
                  child: Material(
                    elevation: 2.5,
                    borderRadius: BorderRadius.circular(size.width * 0.025),
                    child: Container(
                        width: size.width * 0.18,
                        decoration: BoxDecoration(
                          color: AppColor.content.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(size.width * 0.025),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 10.0,
                              right: 5.0,
                              child: Image(
                                height: size.width * 0.07,
                                width: size.width * 0.07,
                                image: AssetImage('assets/img/icon_session.png'),
                                color: AppColor.primaryColor,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              bottom: 35.0,
                              right: 5.0,
                              child: Center(
                                child: Image(
                                  color: AppColor.secondaryColor,
                                  width: size.width * 0.07,
                                  image: AssetImage('assets/img/${AppData().iconRate(session.sessionRate)}'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 30.0,
                              left: 2.0,
                              child: Container(
                                height: 30.0,
                                width: size.width * 0.07,
                                margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                                decoration: BoxDecoration(
                                  // color: AppColor().colorSpecies(session.specie.title),
                                  color: AppColor.secondaryColor,
                                  borderRadius: BorderRadius.circular(size.width * 0.015),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          child: Padding(
                                        padding: const EdgeInsets.only(right: 7.5),
                                        child: Text(
                                          session.strainType!.title!.toLowerCase() == 'unknown'
                                              ? '-'
                                              : session.strainType!.icon.toString().toUpperCase()[0],
                                          style: TextStyle(
                                              color: AppColor.background,
                                              fontSize: size.height * 0.022,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 7.5,
                              child: Container(
                                height: 20.0,
                                width: size.width * 0.16,
                                decoration: BoxDecoration(
                                  color: AppColor.content.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(size.width * 0.01),
                                ),
                                child: Center(
                                    child: Text(
                                  DateFormat('MM/dd/yyyy').format(session.sessionStartTime!),
                                  style: TextStyle(
                                    fontSize: AppFontSizes.contentSmallSize - 1.5,
                                    color: AppColor.primaryColor,
                                  ),
                                )),
                              ),
                            ),
                          ],
                        )),
                  ),
                  onTap: () {
                    print(session.sessionId);
                    loadSessionData(context, session.sessionId);
                  },
                ),
              );
            }),
      );
    }
  }

  loadProfileData(BuildContext context) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse = _prefs.demoVersion
          ? await demoService.demoData(_prefs.id, _prefs.token)
          : await _userProfileServices.loadProfileData(_prefs.id, _prefs.token);

      if (infoResponse['ok']) {
        progressDialog.dismiss();
        if (!_prefs.onboard) {
          Navigator.popAndPushNamed(context, 'onboarding_agree');
        }
        _userSessions = infoResponse['userSessions'];
        setState(() {});
      } else {
        showAlertMessage(context, infoResponse['message'], () {
          Navigator.pop(context);
        });
        print("::Sign Out");
        _prefs.logout();
        Navigator.popAndPushNamed(context, 'signin');
      }
    } catch (e) {
      showAlertMessage(context, "A network error occurred", () {
        Navigator.pop(context);
      });
      print("::Sign Out");
      _prefs.logout();
      Navigator.popAndPushNamed(context, 'signin');
      throw e;
    }
  }

  loadSessionsData(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    if (!_prefs.demoVersion) {
      try {
        Map infoResponse = await _sessionServices.loadSessions(_prefs.id);

        if (infoResponse['ok']) {
          progressDialog.dismiss();

          var dates = infoResponse['sessions'].map((session) => session['session_startTime']['value']).toSet();

          var sessions = <Map<String, dynamic>>[];
          // // loop through all dates
          for (var d in dates) {
            var tranOnDate = infoResponse['sessions']
                .where((session) => DateTime.parse(session['session_startTime']['value']).day == DateTime.parse(d).day)
                .map((session) => Map.from(session)..remove(session))
                .toList();

            sessions.add({"date": d, "sessions": tranOnDate});
          }
          var sessionsEvents = Map<DateTime, List<Event>>.fromIterable(sessions, key: (item) {
            final y = DateFormat('yyyy').format(DateTime.parse(item["date"]));
            final m = DateFormat('MM').format(DateTime.parse(item["date"]));
            final d = DateFormat('dd').format(DateTime.parse(item["date"]));
            return DateTime.utc(int.parse(y), int.parse(m), int.parse(d));
          }, value: (item) {
            List sessions = item["sessions"];
            List<Event> events = [];
            sessions.forEach((session) {
              events.add(
                Event(
                    date: DateTime.parse(session["session_startTime"]['value']),
                    rate: session["session_rate"].toString(),
                    duration: session["session_durationTime"].toString(),
                    id: session["session_id"]),
              );
            });
            return events;
          });
          Navigator.pushNamed(context, 'history', arguments: sessionsEvents);
        } else {
          Navigator.pop(context);
          showAlertMessage(context, infoResponse['message'], () {
            Navigator.pop(context);
          });
        }
      } catch (e) {
        showAlertMessage(context, "A network error occurred", () {
          Navigator.pop(context);
        });
        print("::Sign Out");
        _prefs.logout();
        Navigator.popAndPushNamed(context, 'signin');
        throw e;
      }
    } else {
      progressDialog.dismiss();
      var sessionsEvents = {};
      Navigator.pushNamed(context, 'history', arguments: sessionsEvents);
    }
  }

  loadSessionData(BuildContext context, String? sessionid) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    try {
      Map infoResponse = _prefs.demoVersion ? await demoService.loadSession(_prefs.id) : await _sessionServices.loadSessionbyId(sessionid);

      if (infoResponse['ok']) {
        progressDialog.dismiss();
        Navigator.pushNamed(context, 'session_resume', arguments: infoResponse['session']);
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

  //Resume Session Card
  Widget _resumeSessionCard(BuildContext context, Session session) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.01,
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: size.width * 0.015, bottom: 2.5),
                child: Text(
                  "Condition",
                  style: TextStyle(
                    fontSize: AppFontSizes.contentSmallSize - 1.5,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  height: 30.0,
                  child: Stack(
                    children: [
                      Container(
                        width: size.width * 0.25,
                        decoration: BoxDecoration(
                          color: AppColor.content.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(size.width * 0.025),
                        ),
                        child: Center(
                          child: Text(
                            session.primaryCondition![0].title!,
                            style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSmallSize, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 1.0,
                        child: Image(
                          color: AppColor.secondaryColor,
                          width: 10.0,
                          image: AssetImage('assets/img/icon_arrow.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.005,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: size.width * 0.015, top: 2.5, bottom: 2.5),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Product Type",
                  style: TextStyle(
                    fontSize: AppFontSizes.contentSmallSize - 1.5,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 35,
                child: Stack(
                  children: [
                    Container(
                      width: size.width * 0.25,
                      decoration: BoxDecoration(color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(12.0)),
                      child: Stack(
                        children: [
                          Container(
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Image(
                                color: AppColor.content,
                                width: size.width * 0.06,
                                image: AssetImage('assets/img/medication/${AppData().iconProductType(session.productType!.title!)}'),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: size.width * 0.01),
                              Center(
                                child: Text(
                                  session.productType!.title!,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSmallSize - 1.5, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 1.0,
                      child: Image(
                        color: AppColor.secondaryColor,
                        width: 10.0,
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

  //Resume Time Card
  Widget _resumeTimeCard(BuildContext context, Session session) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.01,
            left: size.width * 0.01,
            right: size.width * 0.02,
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: 2.5),
                child: Text(
                  "Session Date",
                  style: TextStyle(
                    fontSize: AppFontSizes.contentSmallSize - 1.5,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 30.0,
                child: Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      decoration: BoxDecoration(
                        color: AppColor.content.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(size.width * 0.025),
                      ),
                      child: Center(
                        child: Text(
                          '${session.sessionStartTime!.month.toString()}/${session.sessionStartTime!.day.toString()}/${session.sessionStartTime!.year.toString()}',
                          style: TextStyle(color: AppColor.content, fontSize: AppFontSizes.contentSize - 1.0, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 1.0,
                      left: 0.0,
                      child: Image(
                        color: AppColor.secondaryColor,
                        width: 10.0,
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
            top: size.height * 0.008,
            left: size.width * 0.01,
            right: size.width * 0.02,
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: 2.5),
                child: Text(
                  "Session Time",
                  style: TextStyle(
                    fontSize: AppFontSizes.contentSmallSize - 1.5,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 35.0,
                child: Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      decoration: BoxDecoration(
                        color: AppColor.content.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                      ),
                      child: Center(
                        child: Text(
                          showSessionTimeDuration(session),
                          style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.contentSize + 1.0, fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 1.0,
                      left: 0.0,
                      child: Image(
                        color: AppColor.secondaryColor,
                        width: 10.0,
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
}
