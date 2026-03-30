import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beanstalk_mobile/src/services/setup_service.dart';

import '../../preferences/user_preference.dart';

class InventoryServices {
  final String _url = SetupServices.apiURL;
  final _prefs = UserPreference();

  //PRODUCT - LIST
  Future<Map<String, dynamic>> productList(String product) async {
    try {
      print("$_url/inventory/products/$product");
      final response = await http.get(
        Uri.parse('$_url/inventory/products/$product'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //PRODUCTS
        final productsData = decodedResp!['data']['products'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'products': productsData,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //PRODUCT - LIST - LUMIR
  Future<Map<String, dynamic>> lumirProductList() async {
    String country = 'US';
    if (_prefs.country != '') {
      country = _prefs.country;
    }
    try {
      print("$_url/inventory/lumir/products/?country=$country");
      final response = await http.get(
        Uri.parse('$_url/inventory/lumir/products/?country=$country'),
        headers: {
          "Content-Type": "application/json",
          "project_id": _prefs.projectId,
          "company_id": _prefs.appId,
        },
      );

      Map<String, dynamic>? decodedResp = json.decode(response.body);
      print("Response>:$decodedResp");

      if (response.statusCode == 200) {
        //PRODUCTS
        final productsData = decodedResp!['data']['products'];
        return {
          'ok': true,
          'message': decodedResp['message'],
          'products': productsData,
        };
      } else {
        return {'ok': false, 'message': decodedResp!['message']};
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
