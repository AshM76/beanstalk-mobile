import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/canna_measurement_model.dart';
import 'package:beanstalk_mobile/src/models/canna_productType_model.dart';
import 'package:beanstalk_mobile/src/models/canna_strainType_model.dart';
import 'package:beanstalk_mobile/src/models/canna_cannabinoid_model.dart';
import 'package:beanstalk_mobile/src/models/canna_terpene_model.dart';
import 'package:beanstalk_mobile/src/models/session_timeline_model.dart';
import 'package:beanstalk_mobile/src/models/canna_dose_model.dart';

import 'canna_deliveryMethod_model.dart';

class Session {
  Session({
    this.sessionId,
    this.patientId,
    this.primaryCondition,
    this.secondaryCondition,
    this.productType,
    this.deliveryMethodType,
    this.strainType,
    this.productBrand = "",
    this.productName = "",
    this.origin = "",
    this.size = "",
    this.temperature = "",
    this.temperatureMeasurement,
    this.cannabinoids,
    this.terpenes,
    this.activeIngredientsMeasurement,
    this.dose,
    this.doseMeasurement,
    this.sessionNote,
    this.sessionRate = 0,
    this.sessionTimeLines,
    this.sessionStartTime,
    this.sessionEndTime,
    this.sessionDurationTime,
    this.sessionDurationParameter,
    this.sessionStatus,
    this.sessionAdditionalNotes,
  });

  String? sessionId;
  String? patientId;
  List<Condition>? primaryCondition;
  List<Condition>? secondaryCondition;
  ProductType? productType;
  DeliveryMethod? deliveryMethodType;
  StrainType? strainType;
  String? productBrand;
  String? productName;
  //Lumir extra...
  String? origin;
  String? size;
  //
  String? temperature;
  Measurement? temperatureMeasurement;
  List<Cannabinoid>? cannabinoids;
  List<Terpene>? terpenes;
  Measurement? activeIngredientsMeasurement;
  Dose? dose;
  Measurement? doseMeasurement;
  String? sessionNote;
  int sessionRate;
  List<SessionTimeLine>? sessionTimeLines;
  DateTime? sessionStartTime;
  DateTime? sessionEndTime;
  DateTime? sessionDurationTime;
  String? sessionDurationParameter;
  String? sessionStatus;
  List<String>? sessionAdditionalNotes;

  factory Session.fromJsonWidgetList(Map<String, dynamic> parsedJson) {
    List<Condition> primaryConditionsListTemp = [];
    final primaryConditionsResult = parsedJson['session_primaryConditions'] ?? [];
    primaryConditionsResult.forEach((condition) {
      Condition tempSymptom = Condition.fromJson(condition);
      tempSymptom.isSelected = true;
      primaryConditionsListTemp.add(tempSymptom);
    });
    return new Session(
      sessionId: parsedJson['session_id'] ?? "",
      primaryCondition: primaryConditionsListTemp,
      productType: ProductType.fromJson(parsedJson['session_productType']),
      deliveryMethodType: DeliveryMethod.fromJson(parsedJson['session_deliveryMethodType']),
      strainType: StrainType.fromJson(parsedJson['session_strainType']),
      sessionRate: parsedJson['session_rate'] ?? "" as int,
      sessionStartTime: parsedJson.containsKey('session_startTime')
          ? (parsedJson['session_startTime'] is Map
              ? DateTime.parse(parsedJson['session_startTime']['value'])
              : DateTime.parse(parsedJson['session_startTime']))
          : DateTime(0),
      sessionDurationTime:
          parsedJson.containsKey('session_durationTime') ? DateFormat('hh:mm:ss').parse(parsedJson['session_durationTime']) : DateTime(0),
    );
  }

  factory Session.fromJson(Map<String, dynamic> parsedJson) {
    List<Condition> primaryConditionsListTemp = [];
    final primaryConditionsResult = parsedJson['session_primaryConditions'] ?? [];
    primaryConditionsResult.forEach((condition) {
      Condition tempSymptom = Condition.fromJson(condition);
      tempSymptom.isSelected = true;
      primaryConditionsListTemp.add(tempSymptom);
    });

    List<Condition> secondaryConditionsListTemp = [];
    final secondaryConditionsResult = parsedJson['session_secondaryConditions'] ?? [];
    secondaryConditionsResult.forEach((condition) {
      Condition tempSymptom = Condition.fromJson(condition);
      tempSymptom.isSelected = true;
      secondaryConditionsListTemp.add(tempSymptom);
    });

    List<Cannabinoid> cannabinoidsListTemp = [];
    final cannabinoidsResult = parsedJson['session_cannabinoids'] ?? [];
    cannabinoidsResult.forEach((cannabinoid) {
      Cannabinoid tempCannabinoid = Cannabinoid.fromJson(cannabinoid);
      cannabinoidsListTemp.add(tempCannabinoid);
    });

    List<Terpene> terpenesListTemp = [];
    final terpenesResult = parsedJson['session_terpenes'] ?? [];
    terpenesResult.forEach((terpene) {
      Terpene tempTerpene = Terpene.fromJson(terpene);
      terpenesListTemp.add(tempTerpene);
    });

    List<SessionTimeLine> timelinesListTemp = [];
    final timelinesResult = parsedJson['session_timelines'] ?? [];
    timelinesResult.forEach((timeline) {
      SessionTimeLine tempTimeline = SessionTimeLine.fromJson(timeline);
      timelinesListTemp.add(tempTimeline);
    });

    List<String> sessionAdditionalNotesTemp = [];
    final notesResult = parsedJson['session_additional_notes'] ?? [];
    notesResult.forEach((note) {
      sessionAdditionalNotesTemp.add(note);
    });

    return new Session(
        sessionId: parsedJson['session_id'],
        patientId: parsedJson['patient_id'],
        primaryCondition: primaryConditionsListTemp,
        secondaryCondition: secondaryConditionsListTemp,
        productType: ProductType.fromJson(parsedJson['session_productType']),
        deliveryMethodType: DeliveryMethod.fromJson(parsedJson['session_deliveryMethodType']),
        strainType: StrainType.fromJson(parsedJson['session_strainType']),
        productBrand: parsedJson['session_productBrand'] ?? "",
        productName: parsedJson['session_productName'] ?? "",
        //lumir extra...
        origin: parsedJson['session_origin'],
        size: parsedJson['session_size'],
        //
        temperature: parsedJson['session_temperature'],
        temperatureMeasurement: parsedJson.containsKey('session_temperatureMeasurement')
            ? Measurement.fromJson(parsedJson['session_temperatureMeasurement'])
            : Measurement(),
        cannabinoids: cannabinoidsListTemp,
        terpenes: terpenesListTemp,
        activeIngredientsMeasurement: parsedJson.containsKey('session_activeIngredientsMeasurement')
            ? Measurement.fromJson(parsedJson['session_activeIngredientsMeasurement'])
            : Measurement(),
        dose: parsedJson.containsKey('session_dose') ? Dose.fromJson(parsedJson['session_dose']) : Dose(),
        doseMeasurement:
            parsedJson.containsKey('session_doseMeasurement') ? Measurement.fromJson(parsedJson['session_doseMeasurement']) : Measurement(),
        sessionNote: parsedJson['session_note'] ?? "",
        sessionRate: parsedJson['session_rate'] ?? 0,
        sessionTimeLines: timelinesListTemp,
        sessionStartTime: parsedJson.containsKey('session_startTime')
            ? (parsedJson['session_startTime'] is Map
                ? DateTime.parse(parsedJson['session_startTime']['value'])
                : DateTime.parse(parsedJson['session_startTime']))
            : DateTime(0),
        sessionEndTime: parsedJson.containsKey('session_endTime')
            ? (parsedJson['session_endTime'] is Map
                ? DateTime.parse(parsedJson['session_endTime']['value'])
                : DateTime.parse(parsedJson['session_endTime']))
            : DateTime(0),
        sessionDurationTime:
            parsedJson.containsKey('session_durationTime') ? DateFormat('hh:mm:ss').parse(parsedJson['session_durationTime']) : DateTime(0),
        sessionDurationParameter: parsedJson['session_durationParameter'],
        sessionStatus: parsedJson['session_status'],
        sessionAdditionalNotes: sessionAdditionalNotesTemp);
  }

  Map<String, dynamic> toJson() {
    return {
      "session_patientId": this.patientId,
      "session_primaryConditions": this.primaryCondition,
      "session_secondaryConditions": this.secondaryCondition,
      "session_productType": this.productType,
      "session_deliveryMethodType": this.deliveryMethodType,
      "session_strainType": this.strainType,
      "session_productBrand": this.productBrand,
      "session_productName": this.productName,
      "session_origin": this.origin,
      "session_size": this.size,
      "session_temperature": this.temperature,
      "session_temperatureMeasurement": this.temperatureMeasurement,
      "session_cannabinoids": cannabinoids,
      "session_terpenes": this.terpenes,
      "session_activeIngredientsMeasurement": this.activeIngredientsMeasurement,
      "session_dose": this.dose!.toJson(),
      "session_doseMeasurement": this.doseMeasurement,
      "session_note": this.sessionNote,
      "session_rate": this.sessionRate,
      "session_timelines": this.sessionTimeLines,
      "session_startTime": this.sessionStartTime == null ? '2000-01-01T00:00:00' : DateFormat('yyyy-MM-ddTkk:mm:ss').format(this.sessionStartTime!),
      "session_endTime": this.sessionEndTime == null ? '2000-01-01T00:00:00' : DateFormat('yyyy-MM-ddTkk:mm:ss').format(this.sessionEndTime!),
      "session_durationTime": this.sessionDurationTime == null ? '00:00:00' : DateFormat.Hms().format(this.sessionDurationTime!),
      "session_durationParameter": this.sessionDurationParameter,
      "session_status": this.sessionStatus,
      "session_additionalNotes": this.sessionAdditionalNotes
    };
  }
}
