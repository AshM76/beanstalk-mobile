class Employment {
  Employment({
    this.title,
    this.isSelected = false,
  });

  String? title;
  bool isSelected;

  factory Employment.fromJson(Map<String, dynamic> parsedJson) {
    return new Employment(
        title: parsedJson['employment_title'] ?? "",
        isSelected: parsedJson['employment_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "employment_title": this.title,
      "employment_isSelected": this.isSelected,
    };
  }
}
