class Medication {
  Medication({
    this.title,
    this.description,
    this.icon,
    this.preference = "",
    this.experience = "",
    this.isSelected = false,
  });

  String? title;
  String? description;
  String? icon;
  String preference;
  String experience;
  bool isSelected;

  factory Medication.fromJson(Map<String, dynamic> parsedJson) {
    return new Medication(
        title: parsedJson['medication_title'] ?? "",
        description: parsedJson['medication_description'] ?? "",
        icon: parsedJson['medication_icon'] ?? "",
        preference: parsedJson['medication_preference'] ?? "",
        experience: parsedJson['medication_experience'] ?? "",
        isSelected: parsedJson['medication_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "medication_title": this.title,
      "medication_description": this.description,
      "medication_icon": this.icon,
      "medication_preference": this.preference,
      "medication_experience": this.experience,
      "medication_isSelected": this.isSelected,
    };
  }
}
