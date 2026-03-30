import 'package:beanstalk_mobile/src/models/forms/multiple_selection_form_model.dart';
import 'package:beanstalk_mobile/src/models/forms/rate_form_model.dart';
import 'package:beanstalk_mobile/src/models/forms/selection_form_model.dart';

class WeeklyForm {
  WeeklyForm({
    this.number,
    this.title,
    this.kind,
    this.rate,
    this.selection,
    this.multiple,
    this.rated = false,
    this.rateResponse = 0,
    this.selectionResponse = '',
    this.multipleResponse,
  });

  String? number;
  String? title;
  String? kind;
  RateForm? rate;
  List<SelectionForm>? selection;
  List<MultipleSelectionForm>? multiple;
  bool rated;
  int rateResponse;
  String? selectionResponse;
  List<MultipleSelectionForm>? multipleResponse;

  factory WeeklyForm.fromJson(Map<String, dynamic> parsedJson) {
    List<SelectionForm> selectionListTemp = [];
    final selectionResult = parsedJson['selection'] ?? [];
    selectionResult.forEach((selection) {
      SelectionForm tempSelection = SelectionForm.fromJson(selection);
      selectionListTemp.add(tempSelection);
    });

    List<MultipleSelectionForm> multipleListTemp = [];
    final multipleResult = parsedJson['multiple'] ?? [];
    multipleResult.forEach((multiple) {
      MultipleSelectionForm tempMultiple = MultipleSelectionForm.fromJson(multiple);
      multipleListTemp.add(tempMultiple);
    });

    return new WeeklyForm(
      number: parsedJson['number'] ?? "",
      title: parsedJson['title'] ?? "",
      kind: parsedJson['kind'] ?? "",
      rate: parsedJson['rate'] == null ? RateForm(minRate: "0", maxRate: "0") : RateForm.fromJson(parsedJson['rate']),
      selection: selectionListTemp,
      multiple: multipleListTemp,
      multipleResponse: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "number": this.number,
      "title": this.title,
      "kind": this.kind,
      "rate": this.rate,
      "selection": this.selection,
      "multiple": this.multiple,
    };
  }
}
