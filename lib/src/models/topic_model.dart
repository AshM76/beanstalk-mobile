class Condition {
  Condition({
    this.title,
    this.icon,
    this.isSelected = false,
    this.value = 0,
    this.tag = 0,
  });

  String? title;
  String? icon;
  bool isSelected;
  int value;
  int tag;

  factory Condition.fromJson(Map<String, dynamic> parsedJson) {
    return new Condition(
        title: parsedJson['condition_title'] ?? "",
        icon: parsedJson['condition_icon'] ?? "",
        isSelected: parsedJson['condition_isSelected'] ?? false,
        value: parsedJson['condition_value'] ?? 0);
  }

  factory Condition.fromSymptomJson(Map<String, dynamic> parsedJson) {
    return new Condition(
        title: parsedJson['symptom_title'] ?? "",
        icon: parsedJson['symptom__icon'] ?? "",
        isSelected: parsedJson['symptom__isSelected'] ?? false,
        value: parsedJson['symptom__value'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      "condition_title": this.title,
      "condition_icon": this.icon,
      "condition_isSelected": this.isSelected,
      "condition_value": this.value,
    };
  }
}
