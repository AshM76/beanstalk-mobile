import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/blocs/forgotpass_bloc.dart';

import 'package:beanstalk_mobile/src/blocs/signin_bloc.dart';
export 'package:beanstalk_mobile/src/blocs/signin_bloc.dart';

import 'package:beanstalk_mobile/src/blocs/signup_bloc.dart';
export 'package:beanstalk_mobile/src/blocs/signup_bloc.dart';

import 'package:beanstalk_mobile/src/blocs/onboarding_bloc.dart';
export 'package:beanstalk_mobile/src/blocs/onboarding_bloc.dart';

class Provider extends InheritedWidget {
  static Provider? _instance;

  factory Provider({Key? key, Widget? child}) {
    if (_instance == null) {
      _instance = new Provider._internal(key: key, child: child!);
    }
    return _instance!;
  }

  Provider._internal({Key? key, required Widget child}) : super(key: key, child: child);

  final signinBloc = SignInBloc();
  final signupBloc = SignUpBloc();
  final forgotPassBloc = ForgotPassBloc();
  final onboardingBloc = OnboardingBloc();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static SignInBloc siginOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>()!.signinBloc;
  }

  static SignUpBloc signupOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>()!.signupBloc;
  }

  static ForgotPassBloc forgotpassOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()!
        .forgotPassBloc;
  }

  static OnboardingBloc onboardingOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()!
        .onboardingBloc;
  }
}
