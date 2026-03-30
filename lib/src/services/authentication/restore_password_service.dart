import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/setup_service.dart';

class RestorePasswordServices {
  final String _url = SetupServices.apiURL;
  final _prefs = new UserPreference();

  //Password Code Generate
  Future<Map<String, dynamic>> passwordCodeGenerate(String email) async {
    try {
      print("$_url/auth/passwordCodeGenerate");
      final response = await http.get(
        Uri.parse('$_url/auth/passwordCodeGenerate/$email'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        _prefs.email = decodedResp!['data']['user_email'] ?? '';
        return {'ok': true, 'message': decodedResp['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //Password Code Validate
  Future<Map<String, dynamic>> passwordCodeValidate(
      String email, String code) async {
    try {
      print("$_url/auth/passwordCodeValidate");
      final response = await http.get(
        Uri.parse('$_url/auth/passwordCodeValidate/$email/$code'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        _prefs.email = decodedResp!['data']['user_email'] ?? '';
        return {'ok': true, 'message': decodedResp['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //Password Restore
  Future<Map<String, dynamic>> passwordRestore(
      String email, Map<String, dynamic> restore) async {
    try {
      print("$_url/auth/passwordRestore");
      final response = await http.put(
        Uri.parse('$_url/auth/passwordRestore/$email'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
        body: json.encode(restore),
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        _prefs.id = decodedResp!['data']['user_id'] ?? '';
        return {'ok': true, 'message': decodedResp['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
