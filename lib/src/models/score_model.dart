class Measurement {
  Measurement({
    this.title,
    this.increment = 0,
    this.minScale = 0,
    this.maxScale = 0,
    this.isDecimal = false,
    this.isSelected = false,
  });

  String? title;
  double increment;
  double minScale;
  double maxScale;
  bool isDecimal;
  bool isSelected;

  factory Measurement.fromJson(Map<String, dynamic> parsedJson) {
    return new Measurement(
        title: parsedJson['measurement_title'] ?? "",
        increment: parsedJson['measurement_increment'] ?? 0,
        minScale: parsedJson['measurement_minScale'] ?? 0,
        maxScale: parsedJson['measurement_maxScale'] ?? 0,
        isDecimal: parsedJson['measurement_isDecimal'] ?? false,
        isSelected: parsedJson['measurement_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "measurement_title": this.title,
      "measurement_increment": this.increment,
      "measurement_minScale": this.minScale,
      "measurement_maxScale": this.maxScale,
      "measurement_isDecimal": this.isDecimal,
      "measurement_isSelected": this.isSelected,
    };
  }
}
