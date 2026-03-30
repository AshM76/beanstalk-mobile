import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/canna_medication_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_additional_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/setup_service.dart';

class AuthServices {
  final String _url = SetupServices.apiURL;
  final _prefs = new UserPreference();

  //SINGN IN
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final authData = {
      'auth_email': email,
      'auth_password': password,
    };
    try {
      print("$_url/mobile/auth");
      final response = await http.post(Uri.parse('$_url/mobile/auth'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(authData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        _prefs.token = decodedResp!['token'];
        _prefs.id = decodedResp['data']['credential']['account_id'] ?? '';
        _prefs.email = decodedResp['data']['credential']['account_email'] ?? '';
        _prefs.firstname = decodedResp['data']['credential']['account_firstName'] ?? '';
        _prefs.lastname = decodedResp['data']['credential']['account_lastName'] ?? '';
        _prefs.onboard = decodedResp['data']['credential']['isOnboarding'] ?? false;
        return {'ok': true, 'message': decodedResp['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //SINGN UP
  Future<Map<String, dynamic>> signUp(String email, String firstName, String lastName) async {
    // List<Condition> _conditions = [];
    // _prefs.primaryConditions.forEach((condition) {
    //   Map<String, dynamic> temp = jsonDecode(condition);
    //   Condition tempCondition = Condition.fromJson(temp);
    //   _conditions.add(tempCondition);
    // });
    // List<Medication> _medications = [];
    // _prefs.medications.forEach((medication) {
    //   Map<String, dynamic> temp = jsonDecode(medication);
    //   Medication tempMedication = Medication.fromJson(temp);
    //   _medications.add(tempMedication);
    // });
    final authData = {
      'patient_company_id': _prefs.appId,
      'patient_email': email,
      'patient_firstName': firstName,
      'patient_lastName': lastName,
      // 'password': 'password',
      // 'gender': _prefs.gender,
      // 'age': _prefs.age,
      // 'username': _prefs.username,
      // 'phonenumber': _prefs.phonenumber,
      // 'conditions': _conditions,
      // 'medications': _medications,
      //Settings
      // 'marketingEmail': _prefs.marketingEmail,
      // 'marketingText': _prefs.marketingText,
      // 'agreementAccepted': _prefs.agreementAccepted,
      // 'ownerApp': AppInfo.nameApp.toString(),
    };

    try {
      print("$_url/patient");
      final response = await http.post(Uri.parse('$_url/patient'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(authData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        // _prefs.token = decodedResp['token'];
        // _prefs.id = decodedResp['patient']['patient_id'] ?? '';
        return {'ok': true, 'message': decodedResp!['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //ONBOARDING
  Future<Map<String, dynamic>> onboarding() async {
    List<Condition> _primaryConditions = [];
    _prefs.primaryConditions.forEach((condition) {
      Map<String, dynamic> temp = jsonDecode(condition);
      Condition tempCondition = Condition.fromJson(temp);
      _primaryConditions.add(tempCondition);
    });
    List<Condition> _secondaryConditions = [];
    _prefs.secondaryConditions.forEach((condition) {
      Map<String, dynamic> temp = jsonDecode(condition);
      Condition tempCondition = Condition.fromJson(temp);
      _secondaryConditions.add(tempCondition);
    });
    List<Additional> _additionalConditions = [];
    _prefs.additionalConditions.forEach((additional) {
      Map<String, dynamic> temp = jsonDecode(additional);
      Additional tempAdditional = Additional.fromJson(temp);
      _additionalConditions.add(tempAdditional);
    });
    List<Medication> _medications = [];
    _prefs.medications.forEach((medication) {
      Map<String, dynamic> temp = jsonDecode(medication);
      Medication tempMedication = Medication.fromJson(temp);
      _medications.add(tempMedication);
    });
    final authData = {
      'patient_company_id': _prefs.appId,
      'patient_agreement': _prefs.agreementAccepted,
      // 'patient_email': _prefs.email,
      'patient_firstName': _prefs.firstname,
      'patient_lastName': _prefs.lastname,
      'patient_userName': _prefs.username,
      'patient_gender': _prefs.gender,
      'patient_age': _prefs.age != '' ? _prefs.age : null,
      'patient_contact': {
        'phone': _prefs.phonenumber,
      },
      'patient_address': {
        'addressLine1': _prefs.street,
        'city': _prefs.city,
        'state': _prefs.state,
        'zip': _prefs.zip,
        'country': _prefs.country,
      },
      'patient_ethnicity': _prefs.ethnnicity,
      'patient_marital': _prefs.maritalStatus,
      'patient_employment': _prefs.employmentStatus,
      'patient_education': _prefs.education,
      //Conditions
      'patient_primaryConditions': _primaryConditions,
      'patient_secondaryConditions': _secondaryConditions,
      'patient_additionalConditions': _additionalConditions,
      //Medications
      'patient_medications': _medications,
      //Settings
      'marketingEmail': _prefs.marketingEmail,
      'marketingText': _prefs.marketingText,
      //Onboarding
      'patient_onboard': true,
      //Validate Email
      'patient_validateEmail': true,
    };

    try {
      print("$_url/patient/profile/${_prefs.id}");
      final response = await http.put(Uri.parse('$_url/patient/profile/${_prefs.id}'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(authData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        // _prefs.token = decodedResp['token'];
        // _prefs.id = decodedResp['patient']['patient_id'] ?? '';
        return {'ok': true, 'message': decodedResp!['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //Email Verification
  Future<Map<String, dynamic>> emailVerification(String email) async {
    try {
      print("$_url/auth/emailVerification");
      final response = await http.get(
        Uri.parse('$_url/auth/emailVerification/$email'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
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
