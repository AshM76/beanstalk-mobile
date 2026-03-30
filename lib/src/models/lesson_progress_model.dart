class Dose {
  Dose({
    this.value,
    this.position,
  });

  double? value;
  int? position;

  factory Dose.fromJson(Map<String, dynamic> parsedJson) {
    double? value = 0;
    if (parsedJson['dose_value'] is double) {
      value = parsedJson['dose_value'];
    } else if (parsedJson['dose_value'] is int) {
      int valueTemp = parsedJson['dose_value'];
      value = valueTemp.toDouble();
    } else {
      value = double.parse(parsedJson['dose_value']);
    }

    return new Dose(
      value: value,
      position: parsedJson['dose_position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "dose_value": this.value,
      "dose_position": this.position,
    };
  }
}
