import 'dart:async';
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:beanstalk_mobile/src/blocs/validators.dart';

class OnboardingBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _genderController = BehaviorSubject<String>();
  final _ageController = BehaviorSubject<String>();
  final _firstnameController = BehaviorSubject<String>();
  final _lastnameController = BehaviorSubject<String>();
  final _usernameController = BehaviorSubject<String>();
  final _phonenumberController = BehaviorSubject<String>();
  final _phonenumberAUController = BehaviorSubject<String>();

  final _conditionsController = BehaviorSubject<List<Condition>>();

  // ── Age Verification & Parental Consent ────────────────────────
  final _dateOfBirthController = BehaviorSubject<String>();
  final _ageVerificationMethodController = BehaviorSubject<String>();
  final _parentEmailController = BehaviorSubject<String>();
  final _parentNameController = BehaviorSubject<String>();
  final _acceptedConsentsController = BehaviorSubject<Map<String, bool>>();

  // ── Demographics ───────────────────────────────────────────────
  final _educationLevelController = BehaviorSubject<String>();
  final _incomeBracketController = BehaviorSubject<String>();
  final _primaryInterestController = BehaviorSubject<String>();
  final _riskToleranceController = BehaviorSubject<String>();

  //Gets Streams Data
  Stream<String> get emailStream => _emailController.stream.transform(validateEmail);
  Stream<String> get genderStream => _genderController.stream;
  Stream<String> get ageStream => _ageController.stream;
  Stream<String> get firstnameStream => _firstnameController.stream;
  Stream<String> get lastnameStream => _lastnameController.stream;
  Stream<String> get usernameStream => _usernameController.stream;
  Stream<String> get phonenumberStream => _phonenumberController.stream.transform(validatePhoneNumber);
  Stream<String> get phonenumberAUStream => _phonenumberAUController.stream.transform(validateAUPhoneNumber);

  Stream<List<Condition>> get conditionsStream => _conditionsController.stream;

  // Age Verification Streams
  Stream<String> get dateOfBirthStream => _dateOfBirthController.stream;
  Stream<String> get ageVerificationMethodStream => _ageVerificationMethodController.stream;
  Stream<String> get parentEmailStream => _parentEmailController.stream;
  Stream<String> get parentNameStream => _parentNameController.stream;
  Stream<Map<String, bool>> get acceptedConsentsStream => _acceptedConsentsController.stream;

  // Demographics Streams
  Stream<String> get educationLevelStream => _educationLevelController.stream;
  Stream<String> get incomeBracketStream => _incomeBracketController.stream;
  Stream<String> get primaryInterestStream => _primaryInterestController.stream;
  Stream<String> get riskToleranceStream => _riskToleranceController.stream;

  //Gets
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeGender => _genderController.sink.add;
  Function(String) get changeAge => _ageController.sink.add;
  Function(String) get changeFirstname => _firstnameController.sink.add;
  Function(String) get changeLastname => _lastnameController.sink.add;
  Function(String) get changeUsername => _usernameController.sink.add;
  Function(String) get changePhonenumber => _phonenumberController.sink.add;
  Function(String) get changePhonenumberAU => _phonenumberAUController.sink.add;

  Function(List<Condition>) get changeConditions => _conditionsController.sink.add;

  // Age Verification Functions
  Function(String) get changeDateOfBirth => _dateOfBirthController.sink.add;
  Function(String) get changeAgeVerificationMethod => _ageVerificationMethodController.sink.add;
  Function(String) get changeParentEmail => _parentEmailController.sink.add;
  Function(String) get changeParentName => _parentNameController.sink.add;
  Function(Map<String, bool>) get changeAcceptedConsents => _acceptedConsentsController.sink.add;

  // Demographics Functions
  Function(String) get changeEducationLevel => _educationLevelController.sink.add;
  Function(String) get changeIncomeBracket => _incomeBracketController.sink.add;
  Function(String) get changePrimaryInterest => _primaryInterestController.sink.add;
  Function(String) get changeRiskTolerance => _riskToleranceController.sink.add;

  String get email => _emailController.value;
  String get gender => _genderController.value;
  String get age => _ageController.value;
  String get firstname => _firstnameController.value;
  String get lastname => _lastnameController.value;
  String get username => _usernameController.value;
  String get phonenumber => _phonenumberController.value;
  String get phonenumberAU => _phonenumberAUController.value;

  List<Condition> get conditions => _conditionsController.value;

  // Age Verification Getters
  String get dateOfBirth => _dateOfBirthController.value ?? '';
  String get ageVerificationMethod => _ageVerificationMethodController.value ?? '';
  String get parentEmail => _parentEmailController.value ?? '';
  String get parentName => _parentNameController.value ?? '';
  Map<String, bool> get acceptedConsents => _acceptedConsentsController.value ?? {};

  // Demographics Getters
  String get educationLevel => _educationLevelController.value ?? '';
  String get incomeBracket => _incomeBracketController.value ?? '';
  String get primaryInterest => _primaryInterestController.value ?? '';
  String get riskTolerance => _riskToleranceController.value ?? '';

  dispose() {
    _emailController.close();
    _genderController.close();
    _ageController.close();
    _firstnameController.close();
    _lastnameController.close();
    _usernameController.close();
    _phonenumberController.close();
    _phonenumberAUController.close();

    _conditionsController.close();

    // Age Verification & Parental Consent
    _dateOfBirthController.close();
    _ageVerificationMethodController.close();
    _parentEmailController.close();
    _parentNameController.close();
    _acceptedConsentsController.close();

    // Demographics
    _educationLevelController.close();
    _incomeBracketController.close();
    _primaryInterestController.close();
    _riskToleranceController.close();
  }
}
