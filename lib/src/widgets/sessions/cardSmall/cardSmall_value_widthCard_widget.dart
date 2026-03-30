import 'package:flutter/material.dart';

double valueWidthCardSmall(Size size, int value, bool small) {
  if (small) {
    switch (value) {
      case 1:
        return size.width * 0.37;
      default:
        return size.width * 0.32;
    }
  } else {
    switch (value) {
      case 1:
        return size.width * 0.36;
      default:
        return size.width * 0.25;
    }
  }
}
