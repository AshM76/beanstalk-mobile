import 'package:intl/intl.dart';

class SessionTimeLine {
  SessionTimeLine({
    this.type,
    this.title = "",
    this.value = 0.0,
    this.rate = 0,
    this.position = 0,
    this.time,
  });

  String? type;
  String? title;
  double? value;
  int rate;
  int? position;
  DateTime? time;

  factory SessionTimeLine.fromJson(Map<String, dynamic> parsedJson) {
    return new SessionTimeLine(
      type: parsedJson['timeline_type'] ?? "",
      title: parsedJson['timeline_title'] ?? "",
      value: double.parse(parsedJson['timeline_value'].toString()),
      rate: parsedJson['timeline_rate'] ?? 0,
      position: parsedJson['timeline_position'] ?? 0,
      time: parsedJson['timeline_time'] is Map ? DateTime.parse(parsedJson['timeline_time']['value']) : DateTime.parse(parsedJson['timeline_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "timeline_type": this.type,
      "timeline_title": this.title,
      "timeline_value": this.value,
      "timeline_rate": this.rate,
      "timeline_position": this.position,
      "timeline_time": DateFormat('yyyy-MM-ddTkk:mm:ss').format(this.time!),
    };
  }
}
