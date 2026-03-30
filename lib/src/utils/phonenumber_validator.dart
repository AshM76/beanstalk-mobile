import 'package:flutter/services.dart';

class PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    if (newTextLength == 1) {
      if (newValue.text[0] == "(") {
        String result = newValue.text.substring(0, newValue.text.length - 1);
        selectionIndex--;
        return TextEditingValue(
          text: result,
          selection: TextSelection.collapsed(offset: selectionIndex),
        );
      } else {
        newText.write(newValue.text.substring(0, usedSubstringIndex = 0) + '(');
        if (newValue.selection.end >= 0) selectionIndex++;
      }
    }
    if (newTextLength == 5) {
      if (newValue.text[4] == ")") {
        String result = newValue.text.substring(0, newValue.text.length - 1);
        selectionIndex--;
        return TextEditingValue(
          text: result,
          selection: TextSelection.collapsed(offset: selectionIndex),
        );
      } else {
        newText.write(newValue.text.substring(0, usedSubstringIndex = 4) + ') ');
        if (newValue.selection.end >= 4) selectionIndex = selectionIndex + 2;
      }
    }
    if (newTextLength == 10) {
      if (newValue.text[9] == "-") {
        String result = newValue.text.substring(0, newValue.text.length - 1);
        selectionIndex--;
        return TextEditingValue(
          text: result,
          selection: TextSelection.collapsed(offset: selectionIndex),
        );
      } else {
        newText.write(newValue.text.substring(0, usedSubstringIndex = 9) + '-');
        if (newValue.selection.end >= 9) selectionIndex++;
      }
    }

    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) newText.write(newValue.text.substring(usedSubstringIndex));
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class PhoneNumberAUTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    if (newTextLength == 1) {
      if (newValue.text[0] == "(") {
        String result = newValue.text.substring(0, newValue.text.length - 1);
        selectionIndex--;
        return TextEditingValue(
          text: result,
          selection: TextSelection.collapsed(offset: selectionIndex),
        );
      } else {
        newText.write(newValue.text.substring(0, usedSubstringIndex = 0) + '(');
        if (newValue.selection.end >= 0) selectionIndex++;
      }
    }
    if (newTextLength == 4) {
      if (newValue.text[3] == ")") {
        String result = newValue.text.substring(0, newValue.text.length - 1);
        selectionIndex--;
        return TextEditingValue(
          text: result,
          selection: TextSelection.collapsed(offset: selectionIndex),
        );
      } else {
        newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + ') ');
        if (newValue.selection.end >= 3) selectionIndex = selectionIndex + 2;
      }
    }

    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) newText.write(newValue.text.substring(usedSubstringIndex));
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
