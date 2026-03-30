/// Hours class.
class Hours {
  Hours({
    this.day,
    this.opensAt,
    this.closesAt,
  });

  String? day;
  DateTime? opensAt;
  DateTime? closesAt;

  factory Hours.fromJson(Map<String, dynamic> parsedJson) {
    return new Hours(
        day: parsedJson['day'] ?? "",
        opensAt: parsedJson['opensAt'] is Map
            ? DateTime.parse(parsedJson['opensAt']['value'])
            : DateTime.parse(parsedJson['opensAt']),
        closesAt: parsedJson['closesAt'] is Map
            ? DateTime.parse(parsedJson['closesAt']['value'])
            : DateTime.parse(parsedJson['closesAt']));
  }

  Map<String, dynamic> toJson() {
    return {
      "day": this.day,
      "opensAt": this.opensAt,
      "closesAt": this.closesAt,
    };
  }
}
