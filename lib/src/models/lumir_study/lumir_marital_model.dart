class Marital {
  Marital({
    this.title,
    this.isSelected = false,
  });

  String? title;
  bool isSelected;

  factory Marital.fromJson(Map<String, dynamic> parsedJson) {
    return new Marital(
        title: parsedJson['marital_title'] ?? "",
        isSelected: parsedJson['marital_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "marital_title": this.title,
      "marital_isSelected": this.isSelected,
    };
  }
}
