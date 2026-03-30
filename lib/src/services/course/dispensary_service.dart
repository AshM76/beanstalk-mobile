import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/services/setup_service.dart';

import '../../preferences/user_preference.dart';

class DispensaryServices {
  final String _url = SetupServices.apiURL;
  final _prefs = UserPreference();

  //DISPENSARY - LIST
  Future<Map<String, dynamic>> dispensaryList() async {
    try {
      print("$_url/stores");
      final response = await http.get(
        Uri.parse('$_url/stores'),
        headers: {"Content-Type": "application/json", "project_id": _prefs.projectId, "company_id": _prefs.appId, "consumer_id": _prefs.id},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //STORES
        final storesData = decodedResp!['data']['stores'];
        return {'ok': true, 'message': decodedResp['message'], 'stores': storesData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DISPENSARY - LIST SEARCH
  Future<Map<String, dynamic>> dispensaryListBySearch(String search) async {
    try {
      print("$_url/stores?search=$search");
      final response = await http.get(
        Uri.parse('$_url/stores?search=$search'),
        headers: {"Content-Type": "application/json", "project_id": _prefs.projectId, "company_id": _prefs.appId, "consumer_id": _prefs.id},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //STORES
        final storesData = decodedResp!['data']['stores'];
        return {'ok': true, 'message': decodedResp['message'], 'stores': storesData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DISPENSARY - LIST BY ZIP
  Future<Map<String, dynamic>> dispensaryListByZip(String zip) async {
    try {
      print("$_url/stores?zip=$zip");
      final response = await http.get(
        Uri.parse('$_url/stores?zip=$zip'),
        headers: {"Content-Type": "application/json", "project_id": _prefs.projectId, "company_id": _prefs.appId, "consumer_id": _prefs.id},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //STORES
        final storesData = decodedResp!['data']['stores'];
        return {'ok': true, 'message': decodedResp['message'], 'stores': storesData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //DISPENSARY - LIST BY LOCATION
  Future<Map<String, dynamic>> dispensaryListByLocation(double? longitude, double? latitude) async {
    try {
      print("$_url/stores?latitude=$latitude&longitude=$longitude");
      final response = await http.get(
        Uri.parse('$_url/stores?latitude=$latitude&longitude=$longitude'),
        headers: {"Content-Type": "application/json", "project_id": _prefs.projectId, "company_id": _prefs.appId, "consumer_id": _prefs.id},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //STORES
        final storesData = decodedResp!['data']['stores'];
        return {'ok': true, 'message': decodedResp['message'], 'stores': storesData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //STORE - DETAIL
  Future<Map<String, dynamic>> dispensaryDetail(String? storeId) async {
    try {
      print("$_url/stores/$storeId");
      final response = await http.get(
        Uri.parse('$_url/stores/$storeId'),
        headers: {"Content-Type": "application/json", "project_id": _prefs.projectId, "company_id": _prefs.appId, "consumer_id": _prefs.id},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //STORE
        final storeData = decodedResp!['data']['store'];
        return {'ok': true, 'message': decodedResp['message'], 'store': storeData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //STORE - FAVORITES LIST
  Future<Map<String, dynamic>> dispensaryFavoritesList() async {
    try {
      print("$_url/stores?favorites=true");
      final response = await http.get(
        Uri.parse('$_url/stores?favorites=true'),
        headers: {"Content-Type": "application/json", "project_id": _prefs.projectId, "company_id": _prefs.appId, "consumer_id": _prefs.id},
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //STORES
        final storesData = decodedResp!['data']['stores'];
        return {'ok': true, 'message': decodedResp['message'], 'stores': storesData};
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //STORE - SET FAVORITE
  Future<Map<String, dynamic>> dispensarySetFavorite(String storeId, bool? active) async {
    final favoriteData = {
      'favorite': active,
    };

    try {
      print("$_url/stores/favorites");
      final response = await http.post(Uri.parse('$_url/stores/favorites'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
            "consumer_id": _prefs.id,
            "store_id": storeId
          },
          body: json.encode(favoriteData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //Favorite
        bool favorite = decodedResp!['data']['favorite'] == "true" ? true : false;
        return {
          'ok': true,
          'message': decodedResp['message'],
          'favorite': favorite,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //STORE - SET RATING
  Future<Map<String, dynamic>> dispensaryRating(String storeId, double? rating) async {
    final ratingData = {
      'rating': rating,
    };

    try {
      print("$_url/stores/ratings");
      final response = await http.post(Uri.parse('$_url/stores/ratings'),
          headers: {
            "Content-Type": "application/json",
            "project_id": _prefs.projectId,
            "company_id": _prefs.appId,
            "consumer_id": _prefs.id,
            "store_id": storeId
          },
          body: json.encode(ratingData));

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //RATING
        double? rating = 0.0;
        if (decodedResp!['data']['rating'] is double) {
          rating = decodedResp['data']['rating'];
        } else if (decodedResp['data']['rating'] is int) {
          int valueTemp = decodedResp['data']['rating'];
          rating = valueTemp.toDouble();
        } else {
          rating = double.parse(decodedResp['data']['rating']);
        }

        return {
          'ok': true,
          'message': decodedResp['message'],
          'rating': rating,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
