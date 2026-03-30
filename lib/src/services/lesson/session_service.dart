import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/setup_service.dart';

class SessionServices {
  final String _url = SetupServices.apiURL;
  final _prefs = UserPreference();

  //SESSION SAVE
  Future<Map<String, dynamic>> saveSession(Session session) async {
    List<Map<String, dynamic>> timelines = [];
    session.sessionTimeLines!.forEach((timeline) {
      Map<String, dynamic> temp = {
        'timeline_type': timeline.type,
        'timeline_title': timeline.title,
        'timeline_value': timeline.value,
        'timeline_rate': timeline.rate,
        'timeline_position': timeline.position,
        'timeline_time': timeline.time!.hour == 0
            ? DateFormat('yyyy-MM-ddThh:mm:ss').format(timeline.time!)
            : DateFormat('yyyy-MM-ddTkk:mm:ss').format(timeline.time!),
      };
      timelines.add(temp);
    });
    final sessionData = {
      'user_id': _prefs.id,
      'primaryConditions': session.primaryCondition,
      'secondaryConditions': session.secondaryCondition,
      'productType': session.productType,
      'deliveryMethodType': session.deliveryMethodType,
      'strainType': session.strainType,
      'productBrand': session.productBrand,
      'productName': session.productName,
      'temperature': session.temperature,
      'temperatureMeasurement': session.temperatureMeasurement,
      'cannabinoids': session.cannabinoids,
      'terpenes': session.terpenes,
      'activeIngredientsMeasurement': session.activeIngredientsMeasurement,
      'dose': session.dose,
      'doseMeasurement': session.doseMeasurement,
      'note': session.sessionNote,
      'rate': session.sessionRate,
      'timelines': timelines,
      'startTime': session.sessionStartTime!.hour == 0
          ? DateFormat('yyyy-MM-ddThh:mm:ss').format(session.sessionStartTime!)
          : DateFormat('yyyy-MM-ddTkk:mm:ss').format(session.sessionStartTime!),
      'endTime': session.sessionEndTime!.hour == 0
          ? DateFormat('yyyy-MM-ddThh:mm:ss').format(session.sessionEndTime!)
          : DateFormat('yyyy-MM-ddTkk:mm:ss').format(session.sessionEndTime!),
      'durationTime': DateFormat.Hms().format(session.sessionDurationTime!),
      'durationParameter': session.sessionDurationParameter,
      'status': session.sessionStatus,
    };
    try {
      print("$_url/sessions/save");
      final response = await http.post(Uri.parse('$_url/sessions/save'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(sessionData));
      Map<String, dynamic>? decodedResp = json.decode(response.body);
      if (response.statusCode == 200) {
        //SESSION
        final sessionResult = decodedResp!['data']['session'];
        Session session = Session.fromJson(sessionResult);
        return {'ok': true, 'message': decodedResp['message'], 'session': session};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //LOAD SESSIONS
  Future<Map<String, dynamic>> loadSessions(String userId) async {
    try {
      print("$_url/sessions");
      final response = await http.get(
        Uri.parse('$_url/sessions'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
          "user_id": userId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //SESSIONS
        final sessionsData = decodedResp!['data']['sessions'];

        return {'ok': true, 'message': decodedResp['message'], 'sessions': sessionsData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //LOAD SESSION BY ID
  Future<Map<String, dynamic>> loadSessionbyId(String? sessionId) async {
    try {
      print("$_url/sessions/$sessionId");
      final response = await http.get(
        Uri.parse('$_url/sessions/$sessionId'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //SESSION
        final sessionResult = decodedResp!['data']['session'];
        Session session = Session.fromJson(sessionResult);
        return {'ok': true, 'message': decodedResp['message'], 'session': session};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //ADD NOTE SESSION BY ID
  Future<Map<String, dynamic>> addNoteSessionbyId(String? sessionId, String note) async {
    final sessionNote = {'note': note};
    try {
      print("$_url/sessions/addnote/$sessionId");
      final response = await http.put(Uri.parse('$_url/sessions/addnote/$sessionId'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(sessionNote));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //SESSION
        final sessionResult = decodedResp!['data']['session'];
        Session session = Session.fromJson(sessionResult);
        return {'ok': true, 'message': decodedResp['message'], 'session': session};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //TRACK SESSION
  Future<Map<String, dynamic>> startTrackSession(String timers) async {
    final sessionData = {
      'user_id': _prefs.id,
      'tracking': _prefs.tokenNotification,
      'timer': timers,
    };
    try {
      print("$_url/notifications/active");
      final response = await http.post(Uri.parse('$_url/notifications/active'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(sessionData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //SESSION
        return {
          'ok': true,
          'message': decodedResp?['message'],
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> stopTrackSession() async {
    final sessionData = {
      'tracking': _prefs.tokenNotification,
    };
    try {
      print("$_url/notifications/stop");
      final response = await http.post(Uri.parse('$_url/notifications/stop'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(sessionData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //SESSION
        return {
          'ok': true,
          'message': decodedResp?['message'],
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
