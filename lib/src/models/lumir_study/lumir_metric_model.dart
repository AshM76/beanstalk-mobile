class Metric {
  Metric({
    this.title,
    this.isSelected = false,
  });

  String? title;
  bool isSelected;

  factory Metric.fromJson(Map<String, dynamic> parsedJson) {
    return new Metric(title: parsedJson['metric_title'] ?? "", isSelected: parsedJson['metric_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "metric_title": this.title,
      "metric_isSelected": this.isSelected,
    };
  }
}
