import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/services/setup_service.dart';

import '../../preferences/user_preference.dart';

class FormsServices {
  final String _url = SetupServices.apiURL;
  final _prefs = UserPreference();

  //WEEKLY - DATA FORM
  Future<Map<String, dynamic>> dataWeeklyForm(String weeklyFormId) async {
    try {
      print("$_url/forms/weekly/$weeklyFormId");
      final response = await http.get(
        Uri.parse('$_url/forms/weekly/$weeklyFormId'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //Weekly Data Form
        final weeklyForm = decodedResp!['data']['weeklyForm'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'weeklyForm': weeklyForm,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //WEEKLY - SAVE FORM
  Future<Map<String, dynamic>> saveWeeklyForm(String patientId, String weeklyId, String formId, List<Map<String, dynamic>> results) async {
    final weeklyFormData = {
      'weekly_patientId': patientId,
      'weekly_weeklyId': weeklyId,
      'weekly_formId': formId,
      'weekly_results': results,
    };
    try {
      print("$_url/forms/weekly");
      final response = await http.post(
        Uri.parse('$_url/forms/weekly'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
        body: json.encode(weeklyFormData),
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //Weekly Data Form
        final weeklyForm = decodedResp!['data']['weeklyForm'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'weeklyForm': weeklyForm,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
