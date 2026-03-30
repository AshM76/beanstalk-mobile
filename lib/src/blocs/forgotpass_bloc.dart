import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:beanstalk_mobile/src/blocs/validators.dart';

class ForgotPassBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _codeController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _confirmPasswordController = BehaviorSubject<String>();

  //Gets Streams Data
  Stream<String> get emailStream => _emailController.stream.transform(validateEmail);

  Stream<String> get codeStream => _codeController.stream.transform(validateCode);

  Stream<String> get passwordStream => _passwordController.stream.transform(validatePassword);

  Stream<String> get confirmPasswordStream => _confirmPasswordController.stream.transform(validatePassword).doOnData((String c) {
        if (0 != _passwordController.value.compareTo(c)) {
          _confirmPasswordController.addError("\u26A0  Confirmation password do not match");
        }
      });

  Stream<bool> get formEmailValidStream => Rx.combineLatest([emailStream], (values) => true);

  Stream<bool> get formCodeValidStream => Rx.combineLatest([codeStream], (values) => true);

  Stream<bool> get formUpdateValidStream => Rx.combineLatest2(passwordStream, confirmPasswordStream, (dynamic p, dynamic c) => (0 == p.compareTo(c)));

  //Gets
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeCode => _codeController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeConfirmPassword => _confirmPasswordController.sink.add;

  String get email => _emailController.value;
  String get code => _codeController.value;
  String get password => _passwordController.value;
  String get confirmPassword => _confirmPasswordController.value;

  dispose() {
    _emailController.close();
    _codeController.close();
    _passwordController.close();
    _confirmPasswordController.close();
  }
}
