import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/services/setup_service.dart';

import '../../preferences/user_preference.dart';

class DealsServices {
  final String _url = SetupServices.apiURL;
  final _prefs = UserPreference();

  //LOAD DEAL BY ID
  Future<Map<String, dynamic>> loadDealbyId(String dealId) async {
    try {
      print("$_url/deals/$dealId");
      final response = await http.get(
        Uri.parse('$_url/deals/$dealId'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //Deal
        final dealData = decodedResp!['data']['deal'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'deal': dealData,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
