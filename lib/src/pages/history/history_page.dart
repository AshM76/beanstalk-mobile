import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/services/session/session_service.dart';

import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';

import '../../preferences/user_preference.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _prefs = new UserPreference();
  final _sessionServices = SessionServices();

  Map<DateTime, List<Event>>? _sessionsEvents;
  late ValueNotifier<List<Event>> _selectedEvents;
  // DateTime _focusedDay;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  // DateTime _selectedDay;
  final ValueNotifier<DateTime> _selectedDay = ValueNotifier(DateTime.now());

  @override
  void initState() {
    super.initState();
    // _focusedDay = DateTime.now();
    // _selectedDay = DateTime.now();
    _sessionsEvents = {};
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay.value));
  }

  List<Event> _getEventsForDay(DateTime date) {
    return _sessionsEvents![date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    //LoadEvents
    if (!_prefs.demoVersion) {
      _sessionsEvents = ModalRoute.of(context)!.settings.arguments as Map<DateTime, List<Event>>?;
    }

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
            height: size.height,
            width: size.width,
            color: AppColor.background,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Summary",
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
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: TableCalendar(
                      daysOfWeekHeight: 25.0,
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.contentSize),
                        weekendStyle: TextStyle(color: AppColor.primaryColor, fontSize: AppFontSizes.contentSize),
                      ),
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay.value,
                      headerStyle: HeaderStyle(
                        titleTextStyle: TextStyle(color: AppColor.secondaryColor, fontSize: AppFontSizes.subTitleSize),
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),
                      calendarStyle: CalendarStyle(
                        isTodayHighlighted: true,
                        todayTextStyle: TextStyle(color: Colors.white),
                        todayDecoration: BoxDecoration(color: AppColor.content.withOpacity(0.5), shape: BoxShape.circle),
                        selectedTextStyle: TextStyle(color: Colors.white),
                        selectedDecoration: BoxDecoration(color: AppColor.primaryColor, shape: BoxShape.circle),
                        markerSize: 10.0,
                        markerDecoration: BoxDecoration(color: AppColor.secondaryColor, shape: BoxShape.circle),
                      ),
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay.value, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        print(selectedDay.toString());
                        setState(() {
                          _selectedDay.value = selectedDay;
                          _focusedDay.value = focusedDay;
                          _selectedEvents.value = _getEventsForDay(selectedDay);
                        });
                      },
                      eventLoader: _getEventsForDay,
                    )),
                SizedBox(height: size.height * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormat('EEEE MMMM dd, yyyy').format(_selectedDay.value),
                      style: TextStyle(
                        fontSize: AppFontSizes.subTitleSize + (size.width * 0.012),
                        fontFamily: AppFont.primaryFont,
                        color: AppColor.content,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Expanded(
                  child: ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 70,
                            child: InkWell(
                                child: Container(
                                  margin: EdgeInsets.only(left: size.width * 0.14, top: 5.0, bottom: 5.0),
                                  child: Row(
                                    children: [
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
                                                    width: size.width * 0.15,
                                                    padding: EdgeInsets.all(5.0),
                                                    child: Image(
                                                      color: AppColor.secondaryColor,
                                                      image: AssetImage('assets/img/${AppData().iconRate(int.parse(value[index].rate!))}'),
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.0),
                                                  Container(width: 2.5, color: AppColor.content.withOpacity(0.4)),
                                                ],
                                              ),
                                              SizedBox(width: 15.0),
                                              Container(
                                                width: size.width * 0.44,
                                                decoration: BoxDecoration(
                                                  color: AppColor.background.withOpacity(0.8),
                                                  borderRadius: BorderRadius.circular(15.0),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    DateFormat('MM/dd/yyyy - hh:mm a').format(value[index].date!.toLocal()),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12.0,
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
                                onTap: () {
                                  print('${value[index].id}');
                                  loadSessionData(context, value[index].id);
                                }),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.12),
              ],
            )),
      ),
    );
  }

  loadSessionData(BuildContext context, String? sessionid) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    if (!_prefs.demoVersion) {
      try {
        Map infoResponse = await _sessionServices.loadSessionbyId(sessionid);

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
    } else {
      progressDialog.dismiss();
    }
  }
}

class Event {
  Event({
    this.date,
    this.rate,
    this.duration,
    this.id,
  });

  final DateTime? date;
  final String? rate;
  final String? duration;
  final String? id;

  factory Event.fromJson(Map<String, dynamic> parsedJson) {
    return new Event(
      date: parsedJson['date'],
      rate: parsedJson['rate'],
      duration: parsedJson['duration'],
      id: parsedJson['id'],
    );
  }
}
