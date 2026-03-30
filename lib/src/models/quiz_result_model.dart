class Feel {
  Feel({
    this.title,
    this.isSelected = false,
  });

  String? title;
  bool isSelected;

  factory Feel.fromJson(Map<String, dynamic> parsedJson) {
    return new Feel(title: parsedJson['feel_title'] ?? "", isSelected: parsedJson['feel_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "feel_title": this.title,
      "feel_isSelected": this.isSelected,
    };
  }
}
