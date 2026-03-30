import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:beanstalk_mobile/src/blocs/validators.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';

class SignInBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  final _prefs = new UserPreference();

  //Gets Streams Data
  Stream<String> get emailStream => _emailController.stream.transform(validateEmail);
  Stream<String> get passwordStream => _passwordController.stream.transform(validatePassword);

  Stream<bool> get formValidStream => _prefs.demoVersion
      ? Rx.combineLatest([emailStream], (values) => true)
      : Rx.combineLatest2(emailStream, passwordStream, (dynamic e, dynamic p) => true);

  //Gets
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  String get email => _emailController.value;
  String get password => _passwordController.value;

  dispose() {
    _emailController.close();
    _passwordController.close();
  }
}
