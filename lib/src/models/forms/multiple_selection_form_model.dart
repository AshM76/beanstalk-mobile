import 'package:beanstalk_mobile/src/models/forms/multiple_sub_selection_form_model.dart';

class MultipleSelectionForm {
  MultipleSelectionForm({
    this.option,
    this.innerOptions,
    this.isSelected = false,
  });

  String? option;
  List<MultipleSubSelectionForm>? innerOptions;
  bool isSelected;

  factory MultipleSelectionForm.fromJson(Map<String, dynamic> parsedJson) {
    List<MultipleSubSelectionForm> selectionListTemp = [];
    final selectionResult = parsedJson['inner_options'] ?? [];
    selectionResult.forEach((selection) {
      MultipleSubSelectionForm tempSelection = MultipleSubSelectionForm.fromJson(selection);
      selectionListTemp.add(tempSelection);
    });

    return new MultipleSelectionForm(
      option: parsedJson['option'] ?? "",
      innerOptions: selectionListTemp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "option": this.option,
      "innerOptions": this.innerOptions,
    };
  }
}
