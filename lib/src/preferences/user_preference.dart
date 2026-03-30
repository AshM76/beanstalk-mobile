import 'package:shared_preferences/shared_preferences.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';

// Onesignal
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UserPreference {
  static final UserPreference _instance = new UserPreference._internal();

  factory UserPreference() {
    return _instance;
  }

  UserPreference._internal();

  late SharedPreferences _prefs;

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  get projectId {
    return 'beanstalk'; //Beanstalk Project
  }

  get appId {
    return 'ac93844f-956f-468f-8099-4ea727594f20'; //Beanstalk
  }

  /////////////////////////////////////////
  ////
  // USER PROFILE
  ////
  /////////////////////////////////////////
  // GET : SET - _id
  String get id {
    return _prefs.getString('id') ?? '';
  }

  set id(String value) {
    _prefs.setString('id', value);
  }

  // GET : SET - Token
  String get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    _prefs.setString('token', value);
  }

  // GET : SET - Onboard
  bool get onboard {
    return _prefs.getBool('onboard') ?? false;
  }

  set onboard(bool value) {
    _prefs.setBool('onboard', value);
  }

  // GET : SET - email
  String get email {
    return _prefs.getString('email') ?? '';
  }

  set email(String value) {
    _prefs.setString('email', value);
  }

  // GET : SET - password
  String get password {
    return _prefs.getString('password') ?? '';
  }

  set password(String value) {
    _prefs.setString('password', value);
  }

  // GET : SET - firstname
  String get firstname {
    return _prefs.getString('firstname') ?? '';
  }

  set firstname(String value) {
    _prefs.setString('firstname', value);
  }

  // GET : SET - lastname
  String get lastname {
    return _prefs.getString('lastname') ?? '';
  }

  set lastname(String value) {
    _prefs.setString('lastname', value);
  }

  // GET : SET - username
  String get username {
    return _prefs.getString('username') ?? '';
  }

  set username(String value) {
    _prefs.setString('username', value);
  }

  // GET : SET - gender
  String get gender {
    return _prefs.getString('gender') ?? '';
  }

  set gender(String value) {
    _prefs.setString('gender', value);
  }

  // GET : SET - age
  String get age {
    return _prefs.getString('age') ?? '';
  }

  set age(String value) {
    _prefs.setString('age', value);
  }

  // GET : SET - phonenumber
  String get phonenumber {
    return _prefs.getString('phonenumber') ?? '';
  }

  set phonenumber(String value) {
    _prefs.setString('phonenumber', value);
  }

  // GET : SET - country
  String get country {
    return _prefs.getString('country') ?? '';
  }

  set country(String value) {
    _prefs.setString('country', value);
  }

  // GET : SET - street
  String get street {
    return _prefs.getString('street') ?? '';
  }

  set street(String value) {
    _prefs.setString('street', value);
  }

  // GET : SET - city
  String get city {
    return _prefs.getString('city') ?? '';
  }

  set city(String value) {
    _prefs.setString('city', value);
  }

  // GET : SET - state
  String get state {
    return _prefs.getString('state') ?? '';
  }

  set state(String value) {
    _prefs.setString('state', value);
  }

  // GET : SET - zip
  String get zip {
    return _prefs.getString('zip') ?? '';
  }

  set zip(String value) {
    _prefs.setString('zip', value);
  }

  // GET : SET - ethnnicity
  String get ethnnicity {
    return _prefs.getString('ethnnicity') ?? '';
  }

  set ethnnicity(String value) {
    _prefs.setString('ethnnicity', value);
  }

  // GET : SET - maritalStatus
  String get maritalStatus {
    return _prefs.getString('maritalStatus') ?? '';
  }

  set maritalStatus(String value) {
    _prefs.setString('maritalStatus', value);
  }

  // GET : SET - employmentStatus
  String get employmentStatus {
    return _prefs.getString('employmentStatus') ?? '';
  }

  set employmentStatus(String value) {
    _prefs.setString('employmentStatus', value);
  }

  // GET : SET - education
  String get education {
    return _prefs.getString('education') ?? '';
  }

  set education(String value) {
    _prefs.setString('education', value);
  }

  //HEIGHT WEIGHT METRICS
  // GET : SET - height
  String get height {
    return _prefs.getString('height') ?? '';
  }

  set height(String value) {
    _prefs.setString('height', value);
  }

  // GET : SET - height metric
  String get heightMetric {
    return _prefs.getString('heightMetric') ?? '';
  }

  set heightMetric(String value) {
    _prefs.setString('heightMetric', value);
  }

  // GET : SET - weight
  String get weight {
    return _prefs.getString('weight') ?? '';
  }

  set weight(String value) {
    _prefs.setString('weight', value);
  }

  // GET : SET - weight metric
  String get weightMetric {
    return _prefs.getString('weightMetric') ?? '';
  }

  set weightMetric(String value) {
    _prefs.setString('weightMetric', value);
  }

  // GET : SET - cigarettesResponse
  bool get cigarettesResponse {
    return _prefs.getBool('cigarettesResponse') ?? false;
  }

  set cigarettesResponse(bool value) {
    _prefs.setBool('cigarettesResponse', value);
  }

  // GET : SET - cigarettesConsume
  bool get cigarettesConsume {
    return _prefs.getBool('cigarettesConsume') ?? false;
  }

  set cigarettesConsume(bool value) {
    _prefs.setBool('cigarettesConsume', value);
  }

  // GET : SET - cigarettesAmount
  int get cigarettesAmount {
    return _prefs.getInt('cigarettesAmount') ?? 0;
  }

  set cigarettesAmount(int value) {
    _prefs.setInt('cigarettesAmount', value);
  }

  // GET : SET - cannabisResponse
  bool get cannabisResponse {
    return _prefs.getBool('cannabisResponse') ?? false;
  }

  set cannabisResponse(bool value) {
    _prefs.setBool('cannabisResponse', value);
  }

  // GET : SET - cannabisConsume
  bool get cannabisConsume {
    return _prefs.getBool('cannabisConsume') ?? false;
  }

  set cannabisConsume(bool value) {
    _prefs.setBool('cannabisConsume', value);
  }

  // GET : SET - cannabisKind
  List<String> get cannabisKind {
    return _prefs.getStringList('cannabisKind') ?? [];
  }

  set cannabisKind(List<String> value) {
    _prefs.setStringList('cannabisKind', value);
  }

  // GET : SET - cannabisFrequency
  String get cannabisFrequency {
    return _prefs.getString('cannabisFrequency') ?? '';
  }

  set cannabisFrequency(String value) {
    _prefs.setString('cannabisFrequency', value);
  }

  // GET : SET - drugsResponse
  bool get drugsResponse {
    return _prefs.getBool('drugsResponse') ?? false;
  }

  set drugsResponse(bool value) {
    _prefs.setBool('drugsResponse', value);
  }

  // GET : SET - drugsConsume
  bool get drugsConsume {
    return _prefs.getBool('drugsConsume') ?? false;
  }

  set drugsConsume(bool value) {
    _prefs.setBool('drugsConsume', value);
  }

  // GET : SET - drugsKind
  List<String> get drugsKind {
    return _prefs.getStringList('drugsKind') ?? [];
  }

  set drugsKind(List<String> value) {
    _prefs.setStringList('drugsKind', value);
  }

  ///PRIMARY CONDITIONS
  // GET : SET - primaryConditions
  List<String> get primaryConditions {
    return _prefs.getStringList('primaryConditions') ?? [];
  }

  set primaryConditions(List<String> value) {
    _prefs.setStringList('primaryConditions', value);
  }

  ///SECONDARY CONDITIONS
  // GET : SET - secondary conditions
  List<String> get secondaryConditions {
    return _prefs.getStringList('secondaryConditions') ?? [];
  }

  set secondaryConditions(List<String> value) {
    _prefs.setStringList('secondaryConditions', value);
  }

  List<String> get additionalConditions {
    return _prefs.getStringList('additionalConditions') ?? [];
  }

  set additionalConditions(List<String> value) {
    _prefs.setStringList('additionalConditions', value);
  }

  ///SYMPTOMS
  // GET : SET - symptoms
  List<String> get symptoms {
    return _prefs.getStringList('symptoms') ?? [];
  }

  set symptoms(List<String> value) {
    _prefs.setStringList('symptoms', value);
  }

  ///MEDICATIONS
  // GET : SET - medications
  List<String> get medications {
    return _prefs.getStringList('medications') ?? [];
  }

  set medications(List<String> value) {
    _prefs.setStringList('medications', value);
  }

  ///THERAPEUTICS
  // GET : SET - therapeutics
  List<String> get therapeutics {
    return _prefs.getStringList('therapeutics') ?? [];
  }

  set therapeutics(List<String> value) {
    _prefs.setStringList('therapeutics', value);
  }

  /////////////////////////////////////////
  ////
  // USER SETTINGS
  ////
  /////////////////////////////////////////
  ///MARKETING
  // GET : SET - allowMarketingEmail
  bool get marketingEmail {
    return _prefs.getBool('marketingEmail') ?? true;
  }

  set marketingEmail(bool value) {
    _prefs.setBool('marketingEmail', value);
  }

  // GET : SET - allowMarketingText
  bool get marketingText {
    return _prefs.getBool('marketingText') ?? true;
  }

  set marketingText(bool value) {
    _prefs.setBool('marketingText', value);
  }

  ///Receive Deals
  // GET : SET - dealsSettings
  List<String> get dealsSettings {
    return _prefs.getStringList('dealsSettings') ?? [];
  }

  set dealsSettings(List<String> value) {
    _prefs.setStringList('dealsSettings', value);
  }

  ///AGREEMENTS
  // GET : SET - agreementAccepted
  bool get agreementAccepted {
    return _prefs.getBool('agreementAccepted') ?? false;
  }

  set agreementAccepted(bool value) {
    _prefs.setBool('agreementAccepted', value);
  }

  /////////////////////////////////////////
  ////
  // VALIDATE USER
  ////
  /////////////////////////////////////////
  //VALIDATE EMAIL
  // GET : SET - validateEmail
  bool get validateEmail {
    return _prefs.getBool('validateEmail') ?? false;
  }

  set validateEmail(bool value) {
    _prefs.setBool('validateEmail', value);
  }

  //VALIDATE AGE
  // GET : SET - validateAge
  bool get validateAge {
    return _prefs.getBool('validateAge') ?? false;
  }

  set validateAge(bool value) {
    _prefs.setBool('validateAge', value);
  }

  /////////////////////////////////////////
  ////
  //SESSIONS
  ////
  /////////////////////////////////////////
  // GET : SET - userSessions
  List<String> get userSessions {
    return _prefs.getStringList('userSessions') ?? [];
  }

  set userSessions(List<String> value) {
    _prefs.setStringList('userSessions', value);
  }

  // GET : SET - Active Session
  bool get activeSession {
    return _prefs.getBool('activeSession') ?? false;
  }

  set activeSession(bool value) {
    _prefs.setBool('activeSession', value);
  }

  // GET : SET - Current Session
  String get currentSession {
    return _prefs.getString('currentSession') ?? '';
  }

  set currentSession(String value) {
    _prefs.setString('currentSession', value);
  }

  // GET : SET - Last Rates Symptoms in Current Session
  String get lastRateSymptoms {
    return _prefs.getString('lastRateSymptoms') ?? '';
  }

  set lastRateSymptoms(String value) {
    _prefs.setString('lastRateSymptoms', value);
  }

  // GET : SET - Timer Current Session
  String get timerCurrentSession {
    return _prefs.getString('timerCurrentSession') ?? '';
  }

  set timerCurrentSession(String value) {
    _prefs.setString('timerCurrentSession', value);
  }

  // GET : SET - Expired Time Session
  bool get expiredTimeCurrentSession {
    return _prefs.getBool('expiredTimeCurrentSession') ?? false;
  }

  set expiredTimeCurrentSession(bool value) {
    _prefs.setBool('expiredTimeCurrentSession', value);
  }

  /////////////////////////////////////////
  ////
  //CLINICIAN SELECTED
  ////
  /////////////////////////////////////////
  // GET : SET - clinicianPhoto
  String get clinicianPhoto {
    return _prefs.getString('clinicianPhoto') ?? '';
  }

  set clinicianPhoto(String value) {
    _prefs.setString('clinicianPhoto', value);
  }

  /////////////////////////////////////////
  ////
  //NOTIFICATIONS
  ////
  //TOKEN NOTIFICATIONS
  // GET : SET - Token
  String get tokenNotification {
    return _prefs.getString('tokenNotification') ?? '';
  }

  set tokenNotification(String value) {
    _prefs.setString('tokenNotification', value);
  }

  // GET : SET - timeNotifications
  int get timeNotifications {
    return _prefs.getInt('timeNotifications') ?? 15;
  }

  set timeNotifications(int value) {
    _prefs.setInt('timeNotifications', value);
  }

  // GET : SET - numberOfNotification
  int get numberOfNotification {
    return _prefs.getInt('numberOfNotification') ?? 0;
  }

  set numberOfNotification(int value) {
    _prefs.setInt('numberOfNotification', value);
  }

  // GET : SET - lastTimeNotifications
  int get lastTimeNotifications {
    return _prefs.getInt('lastTimeNotifications') ?? 15;
  }

  set lastTimeNotifications(int value) {
    _prefs.setInt('lastTimeNotifications', value);
  }

  clearSession() {
    activeSession = false;
    currentSession = "";
    lastRateSymptoms = '';
    timerCurrentSession = '';
    //NOTIFICATIONS
    timeNotifications = 15;
    numberOfNotification = 0;
  }

  /////////////////////////////////////////
  //CUSTOM ACTIONS
  //GET - screenName
  get screenName {
    bool first = firstname.isEmpty ? false : true;
    bool last = lastname.isEmpty ? false : true;
    if (first && last) {
      return "${_prefs.getString('firstname')} ${_prefs.getString('lastname')}";
    } else if (first && last == false) {
      return "${_prefs.getString('firstname')}";
    } else if (first == false && last) {
      return "${_prefs.getString('lastname')}";
    } else {
      return _prefs.getString('username') ?? '';
    }
  }

  //GET - valueProfile
  get valueProfile {
    int value = 0;
    email.isEmpty ? value = value : value = (value + 10);
    validateEmail ? value = (value + 10) : value = value;
    firstname.isEmpty ? value = value : value = (value + 10);
    username.isEmpty ? value = value : value = (value + 10);
    gender.isEmpty ? value = value : value = (value + 10);
    age.isEmpty ? value = value : value = (value + 10);

    phonenumber.isEmpty ? value = value : value = (value + 10);

    primaryConditions.isEmpty ? value = value : value = (value + 10);
    secondaryConditions.isEmpty ? value = value : value = (value + 10);
    medications.isEmpty ? value = value : value = (value + 10);

    return value;
  }

  /////////////////////////////////////////
  ////
  // LOGOUT
  ////
  logout() {
    _prefs.clear();
    AppData.dataConditions.forEach((condition) {
      condition.isSelected = false;
    });
    //usually called after the user logs out of your app
    OneSignal.logout();
  }

  /////////////////////////////////////////
  ////
  // Demo Version
  ////
  // GET - Demo Version Available
  get demoVersion {
    return false;
  }
}
