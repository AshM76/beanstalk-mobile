import 'package:intl/intl.dart';

/// Chat-Messages class.
class ChatMessage {
  String? id;
  DateTime? date;
  String? content;
  bool read;
  String? type;
  String? sentby;

  ChatMessage({
    this.id,
    this.date,
    this.content,
    this.read = false,
    this.type,
    this.sentby,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> parsedJson) {
    return new ChatMessage(
      id: parsedJson['message_id'] ?? "",
      date: parsedJson['message_date'] is Map ? DateTime.parse(parsedJson['message_date']['value']) : DateTime.parse(parsedJson['message_date']),
      content: parsedJson['message_content'] ?? "",
      read: parsedJson['message_read'] ?? false,
      type: parsedJson['message_type'] ?? "",
      sentby: parsedJson['message_sentby'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message_id": this.id,
      "message_date": DateFormat('yyyy-MM-ddTkk:mm:ss').format(this.date!),
      "message_content": this.content,
      "message_read": this.read,
      "message_type": this.type,
      "message_sentby": this.sentby,
    };
  }
}
