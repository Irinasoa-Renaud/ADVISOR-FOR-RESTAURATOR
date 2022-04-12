import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/utils/constants.dart';

import 'package:path_provider/path_provider.dart' as path_provider;

class Api {
  static const String url = "https://api-advisor.voirlemenu.fr";

  static const String login = url + "/login";
  static const String resetPassword = url + "/users/reset-password";
  static const String confirmResetPwd = url + "/users/confirm-reset-password";
  static const String resendConfirmationCode =
      url + "/users/resend-confirmation-code";

  static const String checkToken = url + "/check-token";

  static const String dashboard = url + "/dashboard";
  static const String commandes = url + '/commands';
  static const String commandsById = commandes + '/id';
  static const String restaurants = url + '/restaurants';

  static const String messages = url + '/messages';
  static const String qrcode = url + '/utils/generate-qrcode';
  static const String acompagnement = url + '/accompaniments';
  // +filter={}
  static const String adminMessage = url + '/adminMessage';
  //  '/${restoId}'

  static const String foods = url + '/foods';
  static const String platRecommander = url + '/platRecommander';
  static const String foodCategories = url + '/foodCategories';
  static const String foodTypes = url + '/foodTypes';
  // ?filter={}

  static const String menus = url + '/menus';

  static const String commandesCount = commandes + '/count';
  static const String messagesCount = messages + '/count';
  // /dashboard/${id}

}

class UserData {
  static String userDataFileName = "user_data.txt";
  static String userDataFileContent = ".";

  static initUserDataFile() async {
    debugPrint("$logTrace init");
    Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = '${directory.path}/$userDataFileName';
    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data = await rootBundle.load('assets/txt/$userDataFileName');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // Save copied asset to documents
      await File(path).writeAsBytes(bytes);
    }
  }

  static Future<File> _getLocalFile() async {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    return File('${directory.path}/$userDataFileName');
  }

  static Future<File> save(String text) async {
    final file = await _getLocalFile();
    return file.writeAsString(text);
  }

// Loads local file into this._localFileContent.
  static Future<String> loadUser() async {
    String content;
    try {
      final file = await _getLocalFile();
      content = await file.readAsString();
    } catch (e) {
      content = 'Error loading local file: $e';
      initUserDataFile();
    }
    // print(content);
    userDataFileContent = content;
    // print("id saved=${this._userDataFileContent}");
    return userDataFileContent;
  }
}

class RestoData {
  static String restoDataFileName = "resto_data.txt";
  static String userDataFileContent = ".";

  static initRestoDataFile() async {
    debugPrint("$logTrace init");
    Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = '${directory.path}/$restoDataFileName';
    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data = await rootBundle.load('assets/txt/$restoDataFileName');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // Save copied asset to documents
      await File(path).writeAsBytes(bytes);
    }
  }

  static Future<File> _getLocalFile() async {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    return File('${directory.path}/$restoDataFileName');
  }

  static Future<File> save(String text) async {
    final file = await _getLocalFile();
    return file.writeAsString(text);
  }

// Loads local file into this._localFileContent.
  static Future<String> loadResto() async {
    String content;
    try {
      final file = await _getLocalFile();
      content = await file.readAsString();
    } catch (e) {
      content = 'Error loading local file: $e';
      initRestoDataFile();
    }
    // print(content);
    userDataFileContent = content;
    // print("id saved=${this._userDataFileContent}");
    return userDataFileContent;
  }
}

class AccessTokenData {
  static String accessTokenDataFileName = "access_token.txt";
  static String accessTokenDataFileContent = ".";

  static initAccessTokenDataFile() async {
    debugPrint("$logTrace init");
    Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = '${directory.path}/$accessTokenDataFileName';
    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data =
          await rootBundle.load('assets/txt/$accessTokenDataFileName');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // Save copied asset to documents
      await File(path).writeAsBytes(bytes);
    }
  }

  static Future<File> _getLocalFile() async {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    return File('${directory.path}/$accessTokenDataFileName');
  }

  static Future<File> saveToken(String text) async {
    final file = await _getLocalFile();
    return file.writeAsString(text);
  }

// Loads local file into this._localFileContent.
  static Future<String> loadToken() async {
    String content;
    try {
      final file = await _getLocalFile();
      content = await file.readAsString();
    } catch (e) {
      content = 'Error loading local file: $e';
      initAccessTokenDataFile();
    }
    // print(content);
    accessTokenDataFileContent = content;
    // print("id saved=${this._userDataFileContent}");
    return accessTokenDataFileContent;
  }
}

class RefreshTokenData {
  static String accessTokenDataFileName = "refresh_token.txt";
  static String accessTokenDataFileContent = ".";

  static initRefreshTokenDataFile() async {
    debugPrint("$logTrace init");
    Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = '${directory.path}/$accessTokenDataFileName';
    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data =
          await rootBundle.load('assets/txt/$accessTokenDataFileName');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // Save copied asset to documents
      await File(path).writeAsBytes(bytes);
    }
  }

  static Future<File> _getLocalFile() async {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    return File('${directory.path}/$accessTokenDataFileName');
  }

  static Future<File> saveToken(String text) async {
    final file = await _getLocalFile();
    return file.writeAsString(text);
  }

// Loads local file into this._localFileContent.
  static Future<String> loadToken() async {
    String content;
    try {
      final file = await _getLocalFile();
      content = await file.readAsString();
    } catch (e) {
      content = 'Error loading local file: $e';
      initRefreshTokenDataFile();
    }
    // print(content);
    accessTokenDataFileContent = content;
    // print("id saved=${this._userDataFileContent}");
    return accessTokenDataFileContent;
  }
}
