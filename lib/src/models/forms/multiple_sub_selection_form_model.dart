class MultipleSubSelectionForm {
  MultipleSubSelectionForm({
    this.option,
    this.isSelected = false,
  });

  String? option;
  bool isSelected;

  factory MultipleSubSelectionForm.fromJson(Map<String, dynamic> parsedJson) {
    return new MultipleSubSelectionForm(
      option: parsedJson['option'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "option": this.option,
    };
  }
}
