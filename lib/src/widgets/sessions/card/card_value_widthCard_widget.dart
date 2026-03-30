import 'package:flutter/material.dart';

double valueWidthCard(Size size, int value, bool popup) {
  switch (value) {
    case 1:
      return popup ? size.width * 0.66 : size.width * 0.70;
    case 2:
      return popup ? size.width * 0.31 : size.width * 0.33;
    default:
      return popup ? size.width * 0.25 : size.width * 0.28;
  }
}
