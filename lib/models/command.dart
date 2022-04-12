import 'package:menu_advisor/models/user.dart';
import 'package:menu_advisor/ui/pages/commandes/detailCommand.dart';

class Command {
  final String id;
  final int code;
  final String createdAt;
  final String updatedAt;
  final int totalPrice;
  final String type;
  final String dateRetrait;
  final bool lePlusTotPossible;
  final bool hasDelivery;
  final bool revoked;
  final bool validated;
  // final DetailCommandFields detailCommandFields;
  Command(
    this.id,
    this.code,
    this.createdAt,
    this.updatedAt,
    this.totalPrice,
    this.type,
    this.dateRetrait,
    this.lePlusTotPossible,
    this.hasDelivery,
    this.revoked,
    this.validated,
    // this.detailCommandFields
  );

  factory Command.fromJson(dynamic json) {
    return Command(
      json['_id'],
      json['code'],
      json['createdAt'],
      json['updatedAt'],
      json['totalPrice'],
      json['commandType'],
      DateTime.fromMillisecondsSinceEpoch(json['shippingTime'] ?? 0).toString(),
      json['shipAsSoonAsPossible'] ?? false,
      json['hasDelivery'] ?? false,
      json['revoked'] ?? false,
      json['validated'] ?? false,
      // json['items'] != null
      //     ? DetailCommandFields.fromJson(json)
      //     : DetailCommandFields.vide()
    );
  }
  @override
  String toString() {
    return '{$id,$code,$createdAt,$updatedAt,$totalPrice,$type,$dateRetrait,$lePlusTotPossible,$hasDelivery,$revoked,$validated}';
  }
}
