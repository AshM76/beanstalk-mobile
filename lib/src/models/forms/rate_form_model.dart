class RateForm {
  RateForm({
    this.minRate,
    this.maxRate,
  });

  String? minRate;
  String? maxRate;

  factory RateForm.fromJson(Map<String, dynamic> parsedJson) {
    return new RateForm(
      minRate: parsedJson['minRate'] ?? "",
      maxRate: parsedJson['maxRate'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "minRate": this.minRate,
      "maxRate": this.maxRate,
    };
  }
}
