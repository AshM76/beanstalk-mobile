import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:beanstalk_mobile/src/blocs/validators.dart';

class SignUpBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _firstnameController = BehaviorSubject<String>();
  final _lastnameController = BehaviorSubject<String>();

  //Gets Streams Data
  Stream<String> get emailStream => _emailController.stream.transform(validateEmail);
  Stream<String> get firstnameStream => _firstnameController.stream;
  Stream<String> get lastnameStream => _lastnameController.stream;

  //Gets
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeFirstname => _firstnameController.sink.add;
  Function(String) get changeLastname => _lastnameController.sink.add;

  Stream<bool> get formValidStream => Rx.combineLatest([emailStream], (values) => true);

  String get email => _emailController.value;
  String get firstname => _firstnameController.value;
  String get lastname => _lastnameController.value;

  dispose() {
    _emailController.close();
    _firstnameController.close();
    _lastnameController.close();
  }
}
