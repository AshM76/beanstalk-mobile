import 'package:beanstalk_mobile/src/models/chatings/chat_message_model.dart';

/// Chat-List class.
class ChatDispensary {
  ChatDispensary({
    this.id,
    this.dispensaryId,
    this.dispensaryName,
    this.storeId,
    this.storeName,
    this.lastMessage,
    this.lastDate,
    this.unreads,
    this.messages,
  });

  String? id;
  String? dispensaryId;
  String? dispensaryName;
  String? storeId;
  String? storeName;
  String? lastMessage;
  DateTime? lastDate;
  int? unreads;
  List<ChatMessage>? messages;

  factory ChatDispensary.fromJson(Map<String, dynamic> parsedJson) {
    List<ChatMessage> messageListTemp = [];
    final messagesResult = parsedJson['chat_messages'] ?? [];
    messagesResult.forEach((message) {
      ChatMessage tempMessage = ChatMessage.fromJson(message);
      messageListTemp.add(tempMessage);
    });

    return new ChatDispensary(
      id: parsedJson['chat_id'] ?? "",
      dispensaryId: parsedJson['chat_dispensary_id'] ?? "",
      dispensaryName: parsedJson['chat_dispensary_name'] ?? "",
      storeId: parsedJson['chat_store_id'] ?? "",
      storeName: parsedJson['chat_store_name'] ?? "",
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
      "chat_dispensary_id": this.dispensaryId,
      "chat_dispensary_name": this.dispensaryName,
      "chat_store_id": this.storeId,
      "chat_store_name": this.dispensaryName,
      "chat_lastMessage": this.lastMessage,
      "chat_lastDate": this.lastMessage,
      "chat_unreads": this.unreads,
      "chat_messages": this.messages,
    };
  }
}
