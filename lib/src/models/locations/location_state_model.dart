class StateLocation {
  StateLocation({
    this.title,
    this.abbreviation,
  });

  String? title;
  String? abbreviation;

  factory StateLocation.fromJson(Map<String, dynamic> parsedJson) {
    return new StateLocation(
      title: parsedJson['state_title'] ?? "",
      abbreviation: parsedJson['state_abbreviation'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "state_title": this.title,
      "state_abbreviation": this.abbreviation,
    };
  }
}
