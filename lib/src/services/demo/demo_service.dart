import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/setup_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import '../../models/canna_condition_model.dart';
import '../../models/canna_medication_model.dart';
import '../../models/canna_symptom_model.dart';
import '../../models/deals/deal_model.dart';
import '../../models/session_model.dart';

class DemoServices {
  final String _url = SetupServices.apiURL;
  final _prefs = new UserPreference();

  //DEMO SINGN
  Future<Map<String, dynamic>> sign(String email) async {
    final authData = {
      'demo_email': email,
      'demo_ownerApp': AppInfo.nameApp.toString(),
    };
    try {
      print("$_url/demo/sign");
      final response = await http.post(Uri.parse('$_url/demo/sign'),
          headers: {"Content-Type": "application/json"},
          body: json.encode(authData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        _prefs.token = decodedResp!['token'];
        _prefs.id = decodedResp['data']['demo_id'] ?? '';
        return {'ok': true, 'message': decodedResp['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DEMO - PROFILE DATA
  Future<Map<String, dynamic>> demoData(String id, String token) async {
    try {
      print("$_url/demo/data/$id");
      final response = await http.get(
        Uri.parse('$_url/demo/data/$id'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );
      print('Token : $token');

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        _prefs.token = decodedResp!['token'] ?? '';
        final userData = decodedResp['data']['user'];
        final sessionsData = decodedResp['data']['sessions'];
        final dealsData = decodedResp['data']['deals'];
        _prefs.id = userData['user_id'] ?? '';
        _prefs.email = userData['user_email'] ?? '';
        _prefs.gender = userData['user_gender'] ?? '';
        _prefs.age = userData['user_age']['value'] ?? '';
        _prefs.firstname = userData['user_firstName'] ?? '';
        _prefs.lastname = userData['user_lastName'] ?? '';
        _prefs.username = userData['user_userName'] ?? '';
        _prefs.phonenumber = userData['user_phoneNumber'] ?? '';
        _prefs.marketingEmail = userData['user_marketingEmail'] ?? false;
        _prefs.marketingText = userData['user_marketingText'] ?? false;
        _prefs.agreementAccepted = userData['user_agreement'] ?? false;
        _prefs.validateEmail = userData['user_validateEmail'] ?? false;
        _prefs.timeNotifications = userData['user_timerNotifications'] ?? 15;

        final conditionsResult = userData['user_conditions'] ?? [];
        List<Condition> conditionsListTemp = [];
        conditionsResult.forEach((condition) {
          Condition tempConditions = Condition.fromJson(condition);
          conditionsListTemp.add(tempConditions);
        });
        List<String> conditionsEncoded = conditionsListTemp
            .map((condition) => jsonEncode(condition))
            .toList();
        _prefs.primaryConditions = conditionsEncoded;

        final symptomResult = userData['user_symptoms'] ?? [];
        List<Symptom> symptomsListTemp = [];
        symptomResult.forEach((symptom) {
          Symptom tempSymptom = Symptom.fromJson(symptom);
          symptomsListTemp.add(tempSymptom);
        });
        List<String> symptomsEncoded =
            symptomsListTemp.map((symptom) => jsonEncode(symptom)).toList();
        _prefs.symptoms = symptomsEncoded;

        final medicationsResult = userData['user_medications'] ?? [];
        List<Medication> medicationsListTemp = [];
        medicationsResult.forEach((medication) {
          Medication tempMedication = Medication.fromJson(medication);
          medicationsListTemp.add(tempMedication);
        });
        List<String> medicationsEncoded = medicationsListTemp
            .map((medication) => jsonEncode(medication))
            .toList();
        _prefs.medications = medicationsEncoded;

        //SESSIONS
        final sessionsResult = sessionsData ?? [];
        List<Session> userSessions = [];
        sessionsResult.forEach((session) {
          Session tempSession = Session.fromJsonWidgetList(session);
          userSessions.add(tempSession);
        });

        //DEALS
        final dealsResult = dealsData ?? [];
        List<Deal> userDeals = [];
        dealsResult.forEach((deal) {
          Deal tempDeal = Deal.fromJsonWidgetList(deal);
          userDeals.add(tempDeal);
        });

        //CHAT UNREADS
        final unreads = decodedResp['data']['chat'] ?? [];
        var userUnreads = 0;
        unreads.forEach((unread) {
          userUnreads = unread['chat_unreads'] ?? 0;
        });

        return {
          'ok': true,
          'message': decodedResp['message'],
          'userSessions': userSessions,
          'userDeals': userDeals,
          'userUnreads': userUnreads,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DEMO - DEAL DATA
  Future<Map<String, dynamic>> loadDeal(String id) async {
    try {
      print("$_url/demo/deals/$id");
      final response = await http.get(
        Uri.parse('$_url/demo/deals/$id'),
        headers: {"Content-Type": "application/json"},
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

  //DEMO - SESSION DATA
  Future<Map<String, dynamic>> loadSession(String id) async {
    try {
      print("$_url/demo/session/$id");
      final response = await http.get(
        Uri.parse('$_url/demo/session/$id'),
        headers: {"Content-Type": "application/json"},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //SESSION
        final sessionResult = decodedResp!['data']['session'];
        Session session = Session.fromJson(sessionResult);
        return {
          'ok': true,
          'message': decodedResp['message'],
          'session': session
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DEMO - STORE LIST
  Future<Map<String, dynamic>> loadStores(String id) async {
    try {
      print("$_url/demo/store/list/${_prefs.id}");
      final response = await http.get(
        Uri.parse('$_url/demo/store/list/${_prefs.id}'),
        headers: {"Content-Type": "application/json"},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //STORES
        final storesData = decodedResp!['data']['stores'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'stores': storesData
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DEMO - STORE DETAIL
  Future<Map<String, dynamic>> loadStoreDetail(String id) async {
    try {
      print("$_url/demo/store/${_prefs.id}");
      final response = await http.get(
        Uri.parse('$_url/demo/store/${_prefs.id}'),
        headers: {"Content-Type": "application/json"},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //STORE
        final storeData = decodedResp!['data']['store'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'store': storeData
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DEMO - CLINICIAN LIST
  Future<Map<String, dynamic>> loadClinicians(String id) async {
    try {
      print("$_url/demo/clinician/list/${_prefs.id}");
      final response = await http.get(
        Uri.parse('$_url/demo/clinician/list/${_prefs.id}'),
        headers: {"Content-Type": "application/json"},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //CLINICIANS
        final cliniciansData = decodedResp!['data']['clinicians'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'clinicians': cliniciansData
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DEMO - CLINICIAN DETAIL
  Future<Map<String, dynamic>> loadClinicianDetail(String id) async {
    try {
      print("$_url/demo/clinician/${_prefs.id}");
      final response = await http.get(
        Uri.parse('$_url/demo/clinician/${_prefs.id}'),
        headers: {"Content-Type": "application/json"},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //CLINICIAN
        final clinicianData = decodedResp!['data']['clinician'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'clinician': clinicianData
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
