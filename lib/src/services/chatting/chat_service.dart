import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/models/chatings/chat_clinician_model.dart';
import 'package:beanstalk_mobile/src/models/chatings/chat_dispensary_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/services/setup_service.dart';

class ChatServices {
  final String _url = SetupServices.apiURL;
  final _prefs = UserPreference();

  //LOAD DISPENSARY-CHAT LIST
  Future<Map<String, dynamic>> loadChatDispensaryList() async {
    try {
      print("$_url/chats/dispensaries");
      final response = await http.get(
        Uri.parse('$_url/chats/dispensaries'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
          "consumer_id": _prefs.id,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //CHAT-DISPENSARY LIST
        final chatsData = decodedResp!['data']['chats'];

        return {'ok': true, 'message': decodedResp['message'], 'chats': chatsData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //LOAD CLINICIAN-CHAT LIST
  Future<Map<String, dynamic>> loadChatClinicianList() async {
    try {
      print("$_url/chats/therapeutics");
      final response = await http.get(
        Uri.parse('$_url/chats/therapeutics'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
          "consumer_id": _prefs.id,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //CHAT-CLINICIAN LIST
        final chatsData = decodedResp!['data']['chats'];

        return {'ok': true, 'message': decodedResp['message'], 'chats': chatsData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //LOAD DISPENSARY-CHAT HISTORY
  Future<Map<String, dynamic>> loadChatDispensaryHistory(String? chatId) async {
    try {
      print("$_url/chats/dispensaries/$chatId");
      final response = await http.get(
        Uri.parse('$_url/chats/dispensaries/$chatId'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
          "consumer_id": _prefs.id,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //CHAT HISTORY
        final chatData = decodedResp!['data']['chat'];

        return {'ok': true, 'message': decodedResp['message'], 'chat': chatData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //LOAD CLINICIAN-CHAT HISTORY
  Future<Map<String, dynamic>> loadChatClinicianHistory(String? chatId) async {
    try {
      print("$_url/chats/therapeutics/$chatId");
      final response = await http.get(
        Uri.parse('$_url/chats/therapeutics/$chatId'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
          "consumer_id": _prefs.id,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //CHAT HISTORY
        final chatData = decodedResp!['data']['chat'];

        return {'ok': true, 'message': decodedResp['message'], 'chat': chatData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //CREATE DISPENSARY-CHAT
  Future<Map<String, dynamic>> createChatDispensary(ChatDispensary chat) async {
    //data
    final chatData = {
      'consumerId': _prefs.id,
      'dispensaryId': chat.dispensaryId,
      'storeId': chat.storeId,
      'messages': chat.messages,
    };

    try {
      print("$_url/chats/dispensaries");
      final response = await http.post(Uri.parse('$_url/chats/dispensaries'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(chatData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //NEW CHAT
        final chatData = decodedResp!['data']['chat'];

        return {'ok': true, 'message': decodedResp['message'], 'chat': chatData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //CREATE CLINICIAN-CHAT
  Future<Map<String, dynamic>> createChatClinician(ChatClinician chat) async {
    //data
    final chatData = {
      'consumerId': _prefs.id,
      'companyId': chat.companyId,
      'clinicianId': chat.clinicianId,
      'messages': chat.messages,
    };

    try {
      print("$_url/chats/therapeutics");
      final response = await http.post(Uri.parse('$_url/chats/therapeutics'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
          },
          body: json.encode(chatData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //NEW CHAT
        final chatData = decodedResp!['data']['chat'];

        return {'ok': true, 'message': decodedResp['message'], 'chat': chatData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
