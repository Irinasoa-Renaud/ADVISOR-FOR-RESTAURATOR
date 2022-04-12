import 'package:menu_advisor/models/user.dart';

class Message {
  String id;
  String name;
  String email;
  String message;
  bool read;
  User? target;
  String createdAt;
  String updatedAt;
  Message(this.id, this.name, this.email, this.message, this.read, this.target,
      this.createdAt, this.updatedAt);

  factory Message.fromJson(dynamic json) {
    return Message(
        json['_id'] ?? "",
        json['name'] ?? "",
        json['email'] ?? "",
        json['message'] ?? "",
        json['read'] ?? false,
        User.fromJson(json['target']),
        json['createdAt'] ?? "",
        json['updatedAt'] ?? "");
  }

  @override
  String toString() {
    return '{$id,$name,$email,$message,$read,$target,$createdAt,$updatedAt}';
  }
}
