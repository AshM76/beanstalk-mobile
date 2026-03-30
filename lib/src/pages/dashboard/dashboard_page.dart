import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/deals/deal_model.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/pages/history/history_page.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/session/session_service.dart';
import 'package:beanstalk_mobile/src/services/user/user_profile_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';
import 'package:beanstalk_mobile/src/widgets/dashboard/dashboard_progressBar_widget.dart';

import '../../models/forms/weekly_pending_form_model.dart';
import '../../services/demo/demo_service.dart';
import '../../widgets/deals/deals_list_widget.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _userProfileServices = UserProfileServices();
  final _sessionServices = SessionServices();
  final _prefs = new UserPreference();

  List<Session> _userSessions = [];
  List<Deal> _userDeals = [];
  List<WeeklyPendingForm> _userPendingWeeklyForm = [];

  int _userUnreadMessages = 0;

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
        floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -25, end: -15),
                // padding: EdgeInsets.all(8),
                badgeContent: Text(
                  _userUnreadMessages.toString(),
                  style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.background),
                ),
                child: Icon(
                  Icons.message_rounded,
                  size: size.height * 0.04,
                ),
                showBadge: _userUnreadMessages > 0 ? true : false,
              ),
              backgroundColor: AppColor.secondaryColor,
              foregroundColor: AppColor.background,
              hoverColor: AppColor.secondaryColor,
              onPressed: () {
                Navigator.pushNamed(context, 'chat_list');
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: Container(
            width: size.width,
            color: AppColor.background,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 50.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hi, ${_prefs.screenName}",
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
                        StaggeredGridTile.extent(
                            crossAxisCellCount: 3,
                            mainAxisExtent: 150.0,
                            child: InkWell(
                                child: _initProfileSection(),
                                onTap: () {
                                  Navigator.pushNamed(context, 'profile').then((_) => setState(() {}));
                                })),
                        StaggeredGridTile.extent(crossAxisCellCount: 3, mainAxisExtent: 2.5, child: _initSpaceSection()),
                        // StaggeredGridTile.extent(crossAxisCellCount: 3, mainAxisExtent: 20.0, child: _initTitleSection("Weekly Research Questions")),
                        // StaggeredGridTile.extent(crossAxisCellCount: 3, mainAxisExtent: 90.0, child: _initWeeklyForms()),
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
                        StaggeredGridTile.extent(crossAxisCellCount: 3, mainAxisExtent: 2.5, child: _initSpaceSection()),
                        StaggeredGridTile.extent(crossAxisCellCount: 3, mainAxisExtent: 20.0, child: _initTitleSection("Communications")),
                        StaggeredGridTile.extent(crossAxisCellCount: 3, mainAxisExtent: 130.0, child: loadDealsList(context, _userDeals)),
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

  Widget _initProfileSection() {
    final size = MediaQuery.of(context).size;
    return Material(
        elevation: 2.5,
        borderRadius: BorderRadius.circular(size.width * 0.05),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * 0.05),
                gradient: AppColor.primaryGradient,
              ),
            ),
            Positioned(
              right: -25,
              top: 0.0,
              child: Image.network(
                AppLogos.iconImg,
                height: 150.0,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.2),
                // color: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              left: 15,
              top: 15.0,
              child: Image.network(
                AppLogos.iconWhiteImg,
                height: 25.0,
                width: 25.0,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 15,
              bottom: 65.0,
              child: Text(
                _prefs.screenName,
                style: TextStyle(
                  fontSize: AppFontSizes.subTitleSize,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 12.5,
              right: 12.5,
              bottom: 25.0,
              child: profileProgressBar(context, _prefs.valueProfile),
            ),
          ],
        ));
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
    if (_userSessions.isEmpty) {
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
            itemCount: _userSessions.length,
            itemBuilder: (BuildContext context, int index) {
              final session = _userSessions[index];
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
                              left: 5.0,
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

  Widget _initWeeklyForms() {
    final size = MediaQuery.of(context).size;
    if (_userPendingWeeklyForm.isEmpty) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size.width * 0.03),
              color: AppColor.content.withOpacity(0.05),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "You do not have weekly forms available, these will appear every week",
                  style: TextStyle(
                    fontSize: AppFontSizes.contentSize - 1.0,
                    color: AppColor.content.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      final weeklyForm = _userPendingWeeklyForm[0];
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.03),
          color: AppColor.content.withOpacity(0.05),
        ),
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Material(
              elevation: 2.5,
              borderRadius: BorderRadius.circular(size.width * 0.03),
              child: Container(
                  width: size.width * 0.18,
                  decoration: BoxDecoration(
                    color: AppColor.content.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(size.width * 0.025),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: size.width * 0.22,
                        child: Center(
                          child: Icon(
                            Icons.pending_actions,
                            size: size.width * 0.15,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: AppColor.content.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(size.width * 0.01),
                                ),
                                child: Center(
                                    child: Text(
                                  "Weekly Form Pending to complete",
                                  style: TextStyle(
                                      fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.secondaryColor, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                )),
                              ),
                              SizedBox(height: 5.0),
                              Container(
                                height: 20.0,
                                decoration: BoxDecoration(
                                  color: AppColor.secondaryColor,
                                  borderRadius: BorderRadius.circular(size.width * 0.01),
                                ),
                                child: Center(
                                    child: Text(
                                  DateFormat('MM/dd/yyyy').format(weeklyForm.formAssignedDate!),
                                  style: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: AppColor.background, fontWeight: FontWeight.w700),
                                )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          onTap: () {
            print("Weekly Form");
            // go to weekly_form with from identifier
            Navigator.pushNamed(context, 'weekly_form', arguments: {
              "weeklyId": weeklyForm.weeklyId,
              "formId": weeklyForm.formId,
            });
          },
        ),
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
        //SESSIONS
        _userSessions = infoResponse['userSessions'] ?? [];
        //DEALS
        _userDeals = infoResponse['userDeals'] ?? [];
        //UNREAD MESSAGES
        _userUnreadMessages = infoResponse['userUnreads'] ?? 0;
        //WEEKLY FORMS
        _userPendingWeeklyForm = infoResponse['userPendingWeeklyForm'] ?? [];
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
}
