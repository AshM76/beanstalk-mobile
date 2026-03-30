class Terpene {
  Terpene({
    this.title,
    this.value = "",
    this.isSelected = false,
  });

  String? title;
  String value;
  bool isSelected;

  factory Terpene.fromJson(Map<String, dynamic> parsedJson) {
    return new Terpene(
      title: parsedJson['terpene_title'] ?? "",
      value: parsedJson['terpene_value'] ?? "",
    );
  }

  factory Terpene.fromLumirJson(Map<String, dynamic> parsedJson) {
    return new Terpene(
      title: parsedJson['title'] ?? "",
      value: parsedJson['amount'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "terpene_title": this.title,
      "terpene_value": this.value,
    };
  }
}
