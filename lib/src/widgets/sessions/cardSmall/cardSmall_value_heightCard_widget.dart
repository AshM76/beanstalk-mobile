import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';

double valueHeightCardSmall(Size size, Session currentSession) {
  double heingCard = 0.425;
  double increment = 0.085;
  if (currentSession.productBrand!.length > 0) {
    heingCard += increment;
  }
  if (currentSession.productName!.length > 0) {
    heingCard += increment;
  }
  if (currentSession.temperature!.length > 0) {
    heingCard += increment;
  }
  if (currentSession.terpenes!.length > 0) {
    heingCard += increment;
  }
  if (currentSession.sessionNote!.length > 0) {
    heingCard += increment;
  }
  return size.height * heingCard;
}
