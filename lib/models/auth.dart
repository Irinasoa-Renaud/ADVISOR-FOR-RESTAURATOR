import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/models/api.dart';

import 'package:http/http.dart' as http;
import 'package:menu_advisor/utils/constants.dart';
import 'package:menu_advisor/utils/dependences.dart';

class Auth {
  static logIn() {}

  static bool logOut() {
    try {
      // UserData.save("none");
      UserData.save("");
      AccessTokenData.saveToken("");
      RefreshTokenData.saveToken("");
      return true;
    } catch (e) {
      debugPrint("$logTrace ereur reseau");
      return false;
    }
  }

  static Future<bool> checkTokenFcn(String aToken, String rToken) async {
    var url = Uri.parse(
        Api.checkToken + "?access_token=$aToken&refresh_token=$rToken");
    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data ${response.body}");
      if (jsonData['validity'] == "valid") {
        return true;
      } else {
        return false;
      }
      // return jsonData;
    } catch (e) {
      debugPrint("$logTrace $e");
      try {
        final response = await InternetAddress.lookup('www.google.com');
        return response.isEmpty ? false : true;
      } on SocketException catch (e) {
        debugPrint("$logTrace $e");
        return false;
      }
    }
  }
}
