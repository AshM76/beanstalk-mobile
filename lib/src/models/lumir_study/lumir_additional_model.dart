class Additional {
  Additional({
    this.title,
    this.isSelected = false,
  });

  String? title;
  bool isSelected;

  factory Additional.fromJson(Map<String, dynamic> parsedJson) {
    return new Additional(
        title: parsedJson['additional_title'] ?? "",
        isSelected: parsedJson['additional_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "additional_title": this.title,
      "additional_isSelected": this.isSelected,
    };
  }
}
