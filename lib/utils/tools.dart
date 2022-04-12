import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as Io;
import 'dependences.dart';

class Tools {
  static Uint8List stringToImg(String uri) {
    Uint8List _bytes = base64.decode(uri.split(',').last);
    return _bytes;
  }

  static String imgToString(File imageFile) {
    var bytes = Io.File(imageFile.path).readAsBytesSync();

    return base64.encode(bytes);
  }

  static String dateTimeToStrFr(DateTime date) {
    var mois = [
      'Janvier',
      'Fevrier',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Aout',
      'Septembre',
      'Octobre',
      'Novembre',
      'Decembre'
    ];
    return "${date.day} ${mois[date.month - 1]} ${date.year}";
  }
}
