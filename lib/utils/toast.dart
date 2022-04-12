import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import 'package:menu_advisor/utils/dependences.dart';

class MyToast {
  static void showAlert(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: UIData.btnAlert,
        textColor: Colors.white);
  }

  static void showSuccess(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: UIData.btnSuccess,
        textColor: Colors.white);
  }

  static void showInfo(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: UIData.btnDefault,
        textColor: Colors.white);
  }
}
