class Symptom {
  Symptom({
    this.title,
    this.value = 0,
    this.isSelected = false,
    this.tag = 0,
    this.isPreference = false,
  });

  String? title;
  int value;
  bool isSelected;
  int tag;
  bool isPreference;

  factory Symptom.fromJson(Map<String, dynamic> parsedJson) {
    return new Symptom(
        title: parsedJson['symptom_title'] ?? "",
        value: parsedJson['symptom_value'] ?? 0,
        isSelected: parsedJson['symptom_isSelected'] ?? false,
        tag: parsedJson['symptom_tag'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      "symptom_title": this.title,
      "symptom_value": this.value,
      "symptom_isSelected": this.isSelected,
      "symptom_tag": this.tag,
    };
  }
}
