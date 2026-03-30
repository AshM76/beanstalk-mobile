import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';

double valueHeightCard(Size size, Session currentSession) {
  double heingCard = 420.0; //size.height * 0.5;
  double increment = 85.0; //size.height * 0.05;

  if (currentSession.temperature!.length > 0) {
    heingCard += 25.0;
  }
  if (currentSession.cannabinoids!.length > 0) {
    heingCard += increment;
  }
  if (currentSession.terpenes!.length > 0) {
    heingCard += increment;
  }
  // if (currentSession.sessionNote.length > 0) {
  //   if (currentSession.sessionNote.length < 60) {
  //     heingCard += increment + 20;
  //   } else if (currentSession.sessionNote.length < 120) {
  //     heingCard += 140;
  //   } else {
  //     heingCard += 220;
  //   }
  // }
  return heingCard;
}
