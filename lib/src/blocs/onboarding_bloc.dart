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

  String get email => _emailController.value;
  String get gender => _genderController.value;
  String get age => _ageController.value;
  String get firstname => _firstnameController.value;
  String get lastname => _lastnameController.value;
  String get username => _usernameController.value;
  String get phonenumber => _phonenumberController.value;
  String get phonenumberAU => _phonenumberAUController.value;

  List<Condition> get conditions => _conditionsController.value;

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
  }
}
