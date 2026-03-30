class StrainType {
  StrainType({
    this.title,
    this.icon,
    this.isSelected = false,
  });

  String? title;
  String? icon;
  bool isSelected;

  factory StrainType.fromJson(Map<String, dynamic> parsedJson) {
    return new StrainType(
        title: parsedJson['strainType_title'] ?? "",
        icon: parsedJson['strainType_icon'] ?? parsedJson['strainType_title'][0].toString().toUpperCase(),
        isSelected: parsedJson['strainType_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "strainType_title": this.title,
      "strainType_icon": this.icon,
      "strainType_isSelected": this.isSelected,
    };
  }
}
