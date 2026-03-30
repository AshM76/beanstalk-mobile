class Education {
  Education({
    this.title,
    this.isSelected = false,
  });

  String? title;
  bool isSelected;

  factory Education.fromJson(Map<String, dynamic> parsedJson) {
    return new Education(
        title: parsedJson['education_title'] ?? "",
        isSelected: parsedJson['education_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "education_title": this.title,
      "education_isSelected": this.isSelected,
    };
  }
}
