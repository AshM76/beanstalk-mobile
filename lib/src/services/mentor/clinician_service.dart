import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/services/setup_service.dart';

import '../../preferences/user_preference.dart';

class ClinicianServices {
  final String _url = SetupServices.apiURL;
  final _prefs = UserPreference();

  //Clinician Search - LIST
  Future<Map<String, dynamic>> clinicianList(String search) async {
    String query = isZipNumeric(search) ? 'zip' : 'search';
    try {
      print("$_url/clinicians?$query=$search");
      final response = await http.get(
        Uri.parse('$_url/clinicians?$query=$search'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //Clinicians
        final cliniciansData = decodedResp!['data']['clinicians'] ?? [];
        return {'ok': true, 'message': decodedResp['message'], 'clinicians': cliniciansData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  bool isZipNumeric(String s) {
    return double.tryParse(s) != null;
  }

  //Clinician Location - LIST
  Future<Map<String, dynamic>> clinicianLocation(String latitude, String longitude) async {
    try {
      print("$_url/clinicians?latitude=$latitude&longitude=$longitude");
      final response = await http.get(
        Uri.parse('$_url/clinicians?latitude=$latitude&longitude=$longitude'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //Clinicians
        final cliniciansData = decodedResp!['data']['clinicians'];
        return {'ok': true, 'message': decodedResp['message'], 'clinicians': cliniciansData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //Clinician - DETAIL
  Future<Map<String, dynamic>> clinicianDetail(String? clinicianId) async {
    try {
      print("$_url/clinicians/$clinicianId");
      final response = await http.get(
        Uri.parse('$_url/clinicians/$clinicianId'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //Clinicians
        final clinicianData = decodedResp!['data']['clinician'];
        return {'ok': true, 'message': decodedResp['message'], 'clinician': clinicianData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
