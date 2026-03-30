class Cannabinoid {
  Cannabinoid({
    this.title,
    this.value = "",
    this.isSelected = false,
  });

  String? title;
  String value;
  bool isSelected;

  factory Cannabinoid.fromJson(Map<String, dynamic> parsedJson) {
    return new Cannabinoid(
      title: parsedJson['cannabinoid_title'] ?? "",
      value: parsedJson['cannabinoid_value'] ?? "-",
    );
  }

  factory Cannabinoid.fromLumirJson(Map<String, dynamic> parsedJson) {
    return new Cannabinoid(
      title: parsedJson['title'] ?? "",
      value: parsedJson['amount'] ?? "-",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cannabinoid_title": this.title,
      "cannabinoid_value": this.value,
    };
  }
}
