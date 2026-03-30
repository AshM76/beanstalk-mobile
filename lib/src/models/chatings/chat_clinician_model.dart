import 'package:beanstalk_mobile/src/models/chatings/chat_message_model.dart';

/// Chat-List class.
class ChatClinician {
  ChatClinician({
    this.id,
    this.companyId,
    this.companyName,
    this.clinicianId,
    this.clinicianName,
    this.lastMessage,
    this.lastDate,
    this.unreads,
    this.messages,
  });

  String? id;
  String? companyId;
  String? companyName;
  String? clinicianId;
  String? clinicianName;
  String? lastMessage;
  DateTime? lastDate;
  int? unreads;
  List<ChatMessage>? messages;

  factory ChatClinician.fromJson(Map<String, dynamic> parsedJson) {
    List<ChatMessage> messageListTemp = [];
    final messagesResult = parsedJson['chat_messages'] ?? [];
    messagesResult.forEach((message) {
      ChatMessage tempMessage = ChatMessage.fromJson(message);
      messageListTemp.add(tempMessage);
    });

    return new ChatClinician(
      id: parsedJson['chat_id'] ?? "",
      companyId: parsedJson['chat_company_id'] ?? "",
      companyName: parsedJson['chat_company_name'] ?? "",
      clinicianId: parsedJson['chat_clinician_id'] ?? "",
      clinicianName: parsedJson['chat_clinician_name'] ?? "",
      lastMessage: parsedJson['chat_lastMessage'] ?? "",
      lastDate:
          parsedJson['chat_lastDate'] is Map ? DateTime.parse(parsedJson['chat_lastDate']['value']) : DateTime.parse(parsedJson['chat_lastDate']),
      unreads: parsedJson['chat_unreads'] ?? 0,
      messages: messageListTemp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chat_id": this.id,
      "chat_company_id": this.companyId,
      "chat_company_name": this.companyName,
      "chat_clinician_id": this.clinicianId,
      "chat_clinician_name": this.clinicianName,
      "chat_lastMessage": this.lastMessage,
      "chat_lastDate": this.lastMessage,
      "chat_unreads": this.unreads,
      "chat_messages": this.messages,
    };
  }
}
