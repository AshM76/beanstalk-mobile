class Ethnicity {
  Ethnicity({
    this.title,
    this.isSelected = false,
  });

  String? title;
  bool isSelected;

  factory Ethnicity.fromJson(Map<String, dynamic> parsedJson) {
    return new Ethnicity(
        title: parsedJson['ethnicity_title'] ?? "",
        isSelected: parsedJson['ethnicity_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "ethnicity_title": this.title,
      "ethnicity_isSelected": this.isSelected,
    };
  }
}
