import 'dart:async';

class Validators {
  final validateEmail = StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern as String);
    if (regExp.hasMatch(email)) {
      sink.add(email);
    } else {
      sink.addError("\u26A0  Invalid email");
    }
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {
    if (password.length >= 6) {
      sink.add(password);
    } else {
      sink.addError("\u26A0  Password must be at least 6 character");
    }
  });

  final validatePhoneNumber = StreamTransformer<String, String>.fromHandlers(handleData: (phoneNumber, sink) {
    Pattern pattern = r'^(\([0-9]{3}\))([ -])([0-9]{3})([ -])([0-9]{4})$';
    //r'^[0-9]{3}(-[0-9]{3})(-[0-9]{4})$';
    //^(?:[+0]9)?[0-9]{10}$'
    RegExp regExp = RegExp(pattern as String);
    if (regExp.hasMatch(phoneNumber)) {
      sink.add(phoneNumber);
    } else {
      sink.addError("\u26A0  Invalid number");
    }
  });

  final validateCode = StreamTransformer<String, String>.fromHandlers(handleData: (phoneNumber, sink) {
    Pattern pattern = r'^[0-9]{6}$';
    RegExp regExp = RegExp(pattern as String);
    if (regExp.hasMatch(phoneNumber)) {
      sink.add(phoneNumber);
    } else {
      sink.addError("\u26A0  Invalid format");
    }
  });

  final validateAUPhoneNumber = StreamTransformer<String, String>.fromHandlers(handleData: (phoneNumber, sink) {
    Pattern pattern = r'^(\([0-9]{2}\))([ ])([0-9]{8})$';
    RegExp regExp = RegExp(pattern as String);
    if (regExp.hasMatch(phoneNumber)) {
      sink.add(phoneNumber);
    } else {
      sink.addError("\u26A0  Invalid number");
    }
  });
}
