class SelectionForm {
  SelectionForm({
    this.option,
    this.value = false,
  });

  String? option;
  bool value;

  factory SelectionForm.fromJson(Map<String, dynamic> parsedJson) {
    return new SelectionForm(
      option: parsedJson['option'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "option": this.option,
    };
  }
}
