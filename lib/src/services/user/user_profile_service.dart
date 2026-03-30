import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/canna_medication_model.dart';
import 'package:beanstalk_mobile/src/models/canna_symptom_model.dart';
import 'package:beanstalk_mobile/src/models/canna_therapeutic_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_additional_model.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/setup_service.dart';

import '../../models/deals/deal_model.dart';
import '../../models/forms/weekly_pending_form_model.dart';

class UserProfileServices {
  final String _url = SetupServices.apiURL;
  final _prefs = new UserPreference();

  //USER - PROFILE
  Future<Map<String, dynamic>> loadUserProfile(String id) async {
    try {
      print("$_url/patient/profile/$id");
      final response = await http.get(
        Uri.parse('$_url/patient/profile/$id'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        final patientData = decodedResp!['data']['patient'];
        _prefs.id = patientData['patient_id'] ?? '';
        _prefs.email = patientData['patient_contact']['email'] ?? '';
        _prefs.agreementAccepted = patientData['patient_agreement'] ?? true;
        _prefs.firstname = patientData['patient_firstName'] ?? '';
        _prefs.lastname = patientData['patient_lastName'] ?? '';
        _prefs.username = patientData['patient_userName'] ?? '';
        _prefs.gender = patientData['patient_gender'] ?? '';
        _prefs.age = patientData['patient_age'] != null ? patientData['patient_age']['value'].toString() : '';

        _prefs.phonenumber = patientData['patient_contact']['phone'] ?? '';

        _prefs.country = patientData['patient_address']['country'] ?? '';
        _prefs.street = patientData['patient_address']['addressLine1'] ?? '';
        _prefs.city = patientData['patient_address']['city'] ?? '';
        _prefs.state = patientData['patient_address']['state'] ?? '';
        _prefs.zip = patientData['patient_address']['zip'] ?? '';

        _prefs.ethnnicity = patientData['patient_ethnicity'] ?? '';
        _prefs.maritalStatus = patientData['patient_marital'] ?? '';
        _prefs.employmentStatus = patientData['patient_employment'] ?? '';
        _prefs.education = patientData['patient_education'] ?? '';

        if (patientData['patient_cigarettes'] != null) {
          _prefs.cigarettesResponse = true;
          _prefs.cigarettesConsume = patientData['patient_cigarettes']['cigarette_consume'] ?? false;
          _prefs.cigarettesAmount = patientData['patient_cigarettes']['cigarette_amountPerDay'] ?? 0;
        } else {
          _prefs.cigarettesResponse = false;
        }

        if (patientData['patient_cannabis'] != null) {
          _prefs.cannabisResponse = true;
          _prefs.cannabisConsume = patientData['patient_cannabis']['cannabis_consume'] ?? null;
          final cannabisKindResult = patientData['patient_cannabis']['cannabis_kindOfUse'] ?? [];
          List<String> cannabiskindListTemp = [];
          cannabisKindResult.forEach((kind) {
            cannabiskindListTemp.add(kind);
          });
          _prefs.cannabisKind = cannabiskindListTemp;
          _prefs.cannabisFrequency = patientData['patient_cannabis']['cannabis_frequencyOfUse'] ?? '';
        } else {
          _prefs.cannabisResponse = false;
        }

        if (patientData['patient_drugs'] != null) {
          _prefs.drugsResponse = true;
          _prefs.drugsConsume = patientData['patient_drugs']['drug_consume'] ?? false;
          final drugsKindResult = patientData['patient_drugs']['drug_kindOfUse'] ?? [];
          List<String> drugskindListTemp = [];
          drugsKindResult.forEach((kind) {
            drugskindListTemp.add(kind);
          });
          _prefs.drugsKind = drugskindListTemp;
        } else {
          _prefs.drugsResponse = false;
        }

        _prefs.height = patientData['patient_height'] ?? '';
        _prefs.heightMetric = patientData['patient_height_metric'] ?? '';
        _prefs.weight = patientData['patient_weight'] ?? '';
        _prefs.weightMetric = patientData['patient_weight_metric'] ?? '';

        final primaryConditionsResult = patientData['patient_primaryConditions'] ?? [];
        List<Condition> primaryConditionsListTemp = [];
        primaryConditionsResult.forEach((condition) {
          Condition tempConditions = Condition.fromJson(condition);
          primaryConditionsListTemp.add(tempConditions);
        });
        List<String> primaryConditionsEncoded = primaryConditionsListTemp.map((condition) => jsonEncode(condition)).toList();
        _prefs.primaryConditions = primaryConditionsEncoded;

        final secondaryConditionsResult = patientData['patient_secondaryConditions'] ?? [];
        List<Condition> secondaryConditionsListTemp = [];
        secondaryConditionsResult.forEach((condition) {
          Condition tempConditions = Condition.fromJson(condition);
          secondaryConditionsListTemp.add(tempConditions);
        });
        List<String> secondaryConditionsEncoded = secondaryConditionsListTemp.map((condition) => jsonEncode(condition)).toList();
        _prefs.secondaryConditions = secondaryConditionsEncoded;

        final additionalConditionsResult = patientData['patient_additionalConditions'] ?? [];
        List<Additional> additionalConditionsListTemp = [];
        additionalConditionsResult.forEach((additional) {
          Additional tempAdditionals = Additional.fromJson(additional);
          additionalConditionsListTemp.add(tempAdditionals);
        });
        List<String> additionalConditionsEncoded = additionalConditionsListTemp.map((additional) => jsonEncode(additional)).toList();
        _prefs.additionalConditions = additionalConditionsEncoded;

        final symptomResult = patientData['patient_symptoms'] ?? [];
        List<Symptom> symptomsListTemp = [];
        symptomResult.forEach((symptom) {
          Symptom tempSymptom = Symptom.fromJson(symptom);
          symptomsListTemp.add(tempSymptom);
        });
        List<String> symptomsEncoded = symptomsListTemp.map((symptom) => jsonEncode(symptom)).toList();
        _prefs.symptoms = symptomsEncoded;

        final medicationsResult = patientData['patient_medications'] ?? [];
        List<Medication> medicationsListTemp = [];
        medicationsResult.forEach((medication) {
          Medication tempMedication = Medication.fromJson(medication);
          medicationsListTemp.add(tempMedication);
        });
        List<String> medicationsEncoded = medicationsListTemp.map((medication) => jsonEncode(medication)).toList();
        _prefs.medications = medicationsEncoded;

        final therapeuticsResult = patientData['patient_therapeutics'] ?? [];
        List<Therapeutic> therapeuticsListTemp = [];
        therapeuticsResult.forEach((therapeutic) {
          Therapeutic tempTherapeutic = Therapeutic.fromJson(therapeutic);
          therapeuticsListTemp.add(tempTherapeutic);
        });
        List<String> therapeuticsEncoded = therapeuticsListTemp.map((therapeutic) => jsonEncode(therapeutic)).toList();
        _prefs.therapeutics = therapeuticsEncoded;

        _prefs.validateEmail = patientData['patient_validateEmail'] ?? false;

        return {'ok': true, 'message': decodedResp['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //USER - UPDATE PROFILE
  Future<Map<String, dynamic>> updateUserProfile(String id, Map<String, dynamic> profile) async {
    try {
      print("$_url/patient/profile/$id");
      final response = await http.put(Uri.parse('$_url/patient/profile/$id'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(profile));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        final patientData = decodedResp!['data']['patient'];
        _prefs.id = patientData['patient_id'] ?? '';
        _prefs.email = patientData['patient_contact']['email'] ?? '';
        _prefs.agreementAccepted = patientData['patient_agreement'] ?? true;
        _prefs.firstname = patientData['patient_firstName'] ?? '';
        _prefs.lastname = patientData['patient_lastName'] ?? '';
        _prefs.username = patientData['patient_userName'] ?? '';
        _prefs.gender = patientData['patient_gender'] ?? '';
        _prefs.age = patientData['patient_age'] != null ? patientData['patient_age']['value'].toString() : '';
        _prefs.phonenumber = patientData['patient_contact']['phone'] ?? '';

        _prefs.ethnnicity = patientData['patient_ethnicity'] ?? '';
        _prefs.maritalStatus = patientData['patient_marital'] ?? '';
        _prefs.employmentStatus = patientData['patient_employment'] ?? '';
        _prefs.education = patientData['patient_education'] ?? '';

        if (patientData['patient_cigarettes'] != null) {
          _prefs.cigarettesResponse = true;
          _prefs.cigarettesConsume = patientData['patient_cigarettes']['cigarette_consume'] ?? false;
          _prefs.cigarettesAmount = patientData['patient_cigarettes']['cigarette_amountPerDay'] ?? 0;
        } else {
          _prefs.cigarettesResponse = false;
        }

        if (patientData['patient_cannabis'] != null) {
          _prefs.cannabisResponse = true;
          _prefs.cannabisConsume = patientData['patient_cannabis']['cannabis_consume'] ?? null;
          final cannabisKindResult = patientData['patient_cannabis']['cannabis_kindOfUse'] ?? [];
          List<String> cannabiskindListTemp = [];
          cannabisKindResult.forEach((kind) {
            cannabiskindListTemp.add(kind);
          });
          _prefs.cannabisKind = cannabiskindListTemp;
          _prefs.cannabisFrequency = patientData['patient_cannabis']['cannabis_frequencyOfUse'] ?? '';
        } else {
          _prefs.cannabisResponse = false;
        }

        if (patientData['patient_drugs'] != null) {
          _prefs.drugsResponse = true;
          _prefs.drugsConsume = patientData['patient_drugs']['drug_consume'] ?? false;
          final drugsKindResult = patientData['patient_drugs']['drug_kindOfUse'] ?? [];
          List<String> drugskindListTemp = [];
          drugsKindResult.forEach((kind) {
            drugskindListTemp.add(kind);
          });
          _prefs.drugsKind = drugskindListTemp;
        } else {
          _prefs.drugsResponse = false;
        }

        _prefs.height = patientData['patient_height'] ?? '';
        _prefs.heightMetric = patientData['patient_height_metric'] ?? '';
        _prefs.weight = patientData['patient_weight'] ?? '';
        _prefs.weightMetric = patientData['patient_weight_metric'] ?? '';

        final primaryConditionsResult = patientData['patient_primaryConditions'] ?? [];
        List<Condition> primaryConditionsListTemp = [];
        primaryConditionsResult.forEach((condition) {
          Condition tempConditions = Condition.fromJson(condition);
          primaryConditionsListTemp.add(tempConditions);
        });
        List<String> primaryConditionsEncoded = primaryConditionsListTemp.map((condition) => jsonEncode(condition)).toList();
        _prefs.primaryConditions = primaryConditionsEncoded;

        final secondaryConditionsResult = patientData['patient_secondaryConditions'] ?? [];
        List<Condition> secondaryConditionsListTemp = [];
        secondaryConditionsResult.forEach((condition) {
          Condition tempConditions = Condition.fromJson(condition);
          secondaryConditionsListTemp.add(tempConditions);
        });
        List<String> secondaryConditionsEncoded = secondaryConditionsListTemp.map((condition) => jsonEncode(condition)).toList();
        _prefs.secondaryConditions = secondaryConditionsEncoded;

        final additionalConditionsResult = patientData['patient_additionalConditions'] ?? [];
        List<Additional> additionalConditionsListTemp = [];
        additionalConditionsResult.forEach((additional) {
          Additional tempAdditionals = Additional.fromJson(additional);
          additionalConditionsListTemp.add(tempAdditionals);
        });
        List<String> additionalConditionsEncoded = additionalConditionsListTemp.map((additional) => jsonEncode(additional)).toList();
        _prefs.additionalConditions = additionalConditionsEncoded;

        final symptomResult = patientData['patient_symptoms'] ?? [];
        List<Symptom> symptomsListTemp = [];
        symptomResult.forEach((symptom) {
          Symptom tempSymptom = Symptom.fromJson(symptom);
          symptomsListTemp.add(tempSymptom);
        });
        List<String> symptomsEncoded = symptomsListTemp.map((symptom) => jsonEncode(symptom)).toList();
        _prefs.symptoms = symptomsEncoded;

        final medicationsResult = patientData['patient_medications'] ?? [];
        List<Medication> medicationsListTemp = [];
        medicationsResult.forEach((medication) {
          Medication tempMedication = Medication.fromJson(medication);
          medicationsListTemp.add(tempMedication);
        });
        List<String> medicationsEncoded = medicationsListTemp.map((medication) => jsonEncode(medication)).toList();
        _prefs.medications = medicationsEncoded;

        final therapeuticsResult = patientData['patient_therapeutics'] ?? [];
        List<Therapeutic> therapeuticsListTemp = [];
        therapeuticsResult.forEach((therapeutic) {
          Therapeutic tempTherapeutic = Therapeutic.fromJson(therapeutic);
          therapeuticsListTemp.add(tempTherapeutic);
        });
        List<String> therapeuticsEncoded = therapeuticsListTemp.map((therapeutic) => jsonEncode(therapeutic)).toList();
        _prefs.therapeutics = therapeuticsEncoded;

        return {'ok': true, 'message': decodedResp['message']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //USER - Username Validation
  Future<Map<String, dynamic>> usernameVerification(String username) async {
    try {
      print("$_url/auth/usernameVerification/$username");
      final response = await http.get(
        Uri.parse('$_url/auth/usernameVerification/$username'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        return {'ok': true, 'message': decodedResp!['message'], 'validate': decodedResp['validate']};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //USER - PROFILE DATA
  Future<Map<String, dynamic>> loadProfileData(String id, String token) async {
    try {
      print("$_url/patient/data/$id");
      final response = await http.get(
        Uri.parse('$_url/patient/data/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );
      print('Token : $token');

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        _prefs.token = decodedResp!['token'] ?? '';
        final patientData = decodedResp['data']['patient'];
        final sessionsData = decodedResp['data']['sessions'];
        final dealsData = decodedResp['data']['deals'];
        final weeklyFormsData = decodedResp['data']['weeklyForms'];
        _prefs.id = patientData['patient_id'] ?? '';
        _prefs.email = patientData['patient_email'] ?? '';
        _prefs.firstname = patientData['patient_firstName'] ?? '';
        _prefs.lastname = patientData['patient_lastName'] ?? '';
        _prefs.onboard = patientData['isOnboarding'] ?? false;
        // _prefs.gender = userData['user_gender'] ?? '';
        // _prefs.age = userData['user_age']['value'] ?? '';
        // _prefs.username = userData['user_userName'] ?? '';
        // _prefs.phonenumber = userData['user_phoneNumber'] ?? '';
        // _prefs.marketingEmail = userData['user_marketingEmail'] ?? false;
        // _prefs.marketingText = userData['user_marketingText'] ?? false;
        // _prefs.agreementAccepted = userData['user_agreement'] ?? false;
        // _prefs.validateEmail = userData['user_validateEmail'] ?? false;
        // _prefs.timeNotifications = userData['user_timerNotifications'] ?? 15;

        final primaryConditionsResult = patientData['patient_primaryConditions'] ?? [];
        List<Condition> primaryConditionsListTemp = [];
        primaryConditionsResult.forEach((condition) {
          Condition tempConditions = Condition.fromJson(condition);
          primaryConditionsListTemp.add(tempConditions);
        });
        List<String> primaryConditionsEncoded = primaryConditionsListTemp.map((condition) => jsonEncode(condition)).toList();
        _prefs.primaryConditions = primaryConditionsEncoded;

        final secondaryConditionsResult = patientData['patient_secondaryConditions'] ?? [];
        List<Condition> secondaryConditionsListTemp = [];
        secondaryConditionsResult.forEach((condition) {
          Condition tempConditions = Condition.fromJson(condition);
          secondaryConditionsListTemp.add(tempConditions);
        });
        List<String> secondaryConditionsEncoded = secondaryConditionsListTemp.map((condition) => jsonEncode(condition)).toList();
        _prefs.secondaryConditions = secondaryConditionsEncoded;

        // final conditionsResult = userData['user_conditions'] ?? [];
        // List<Condition> conditionsListTemp = [];
        // conditionsResult.forEach((condition) {
        //   Condition tempConditions = Condition.fromJson(condition);
        //   conditionsListTemp.add(tempConditions);
        // });
        // List<String> conditionsEncoded = conditionsListTemp
        //     .map((condition) => jsonEncode(condition))
        //     .toList();
        // _prefs.primaryConditions = conditionsEncoded;

        // final symptomResult = userData['user_symptoms'] ?? [];
        // List<Symptom> symptomsListTemp = [];
        // symptomResult.forEach((symptom) {
        //   Symptom tempSymptom = Symptom.fromJson(symptom);
        //   symptomsListTemp.add(tempSymptom);
        // });
        // List<String> symptomsEncoded =
        //     symptomsListTemp.map((symptom) => jsonEncode(symptom)).toList();
        // _prefs.symptoms = symptomsEncoded;

        // final medicationsResult = userData['user_medications'] ?? [];
        // List<Medication> medicationsListTemp = [];
        // medicationsResult.forEach((medication) {
        //   Medication tempMedication = Medication.fromJson(medication);
        //   medicationsListTemp.add(tempMedication);
        // });
        // List<String> medicationsEncoded = medicationsListTemp
        //     .map((medication) => jsonEncode(medication))
        //     .toList();
        // _prefs.medications = medicationsEncoded;

        final therapeuticsResult = patientData['patient_therapeutics'] ?? [];
        List<Therapeutic> therapeuticsListTemp = [];
        therapeuticsResult.forEach((therapeutic) {
          Therapeutic tempTherapeutic = Therapeutic.fromJson(therapeutic);
          therapeuticsListTemp.add(tempTherapeutic);
        });
        List<String> therapeuticsEncoded = therapeuticsListTemp.map((therapeutic) => jsonEncode(therapeutic)).toList();
        _prefs.therapeutics = therapeuticsEncoded;

        //SESSIONS
        final sessionsResult = sessionsData ?? [];
        List<Session> userSessions = [];
        sessionsResult.forEach((session) {
          print(session);
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

        //UNREAD MESSAGES
        final unreads = decodedResp['data']['chat'] ?? [];
        var userUnreads;
        unreads.forEach((unread) {
          userUnreads = unread['chat_unreads'] ?? 0;
        });

        //WEEKLY FORMS
        final pendingsResult = weeklyFormsData ?? [];
        List<WeeklyPendingForm> userPendingWeeklyForm = [];
        pendingsResult.forEach((weeklyForm) {
          WeeklyPendingForm tempWeeklyForm = WeeklyPendingForm.fromJson(weeklyForm);
          userPendingWeeklyForm.add(tempWeeklyForm);
        });

        return {
          'ok': true,
          'message': decodedResp['message'],
          'userSessions': userSessions,
          'userDeals': userDeals,
          'userUnreads': userUnreads,
          'userPendingWeeklyForm': userPendingWeeklyForm,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
