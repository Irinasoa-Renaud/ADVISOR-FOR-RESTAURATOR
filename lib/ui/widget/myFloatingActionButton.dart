import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/utils/dependences.dart';

import 'package:http/http.dart' as http;

class MyFloatingActionButton extends StatefulWidget {
  const MyFloatingActionButton({
    Key? key,
  }) : super(key: key);

  @override
  _MyFloatingActionButtonState createState() => _MyFloatingActionButtonState();
}

class _MyFloatingActionButtonState extends State<MyFloatingActionButton> {
  String aToken = "", rToken = "";
  int count = 0;
  Future<int> getMessagesCount(String userId) async {
    setState(() {
      // userId = "";
    });
    var url = Uri.parse(Api.messagesCount +
        (userId != ""
            ? '?filter={"target":"$userId","read":"false"}'
            : '?filter={}'));
    int count = 0;
    try {
      debugPrint("$logTrace $url");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $aToken',
      });
      var jsonData = json.decode(response.body);
      debugPrint("$logTrace data:mess ${response.body.toString()}");
      setState(() {
        count = jsonData["count"];
      });

      return count;
    } catch (e) {
      debugPrint("$logTrace error $e");
      return 0;
    }
  }

  @override
  void initState() {
    AccessTokenData.loadToken().then((value) {
      debugPrint("$logTrace tokenLoaded $value");
      setState(() {
        aToken = value;
      });
      RefreshTokenData.loadToken().then((value) {
        debugPrint("$logTrace rtokenLoaded $value");
        setState(() {
          rToken = value;
        });
        UserData.loadUser().then((value) {
          User user = User.fromJson(json.decode(value)['user']);
          getMessagesCount(user.id).then((value) {
            setState(() {
              count = value;
            });
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Fab
    return FAB(count);
    // return FutureBuilder(
    //   future: getMessagesCount(),
    //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //     return FAB(snapshot.hasData ? snapshot.data : 0);
    //   },
    // );
  }

  Widget FAB(int val) {
    return Badge(
      showBadge: (val).toString().padLeft(2, "0") == "00" ? false : true,
      badgeColor: UIData.colorPrincipal,
      badgeContent: Text(
        (val) > 0 ? (val).toString().padLeft(2, "0") : "",
        style: const TextStyle(color: Colors.white),
      ),
      position: BadgePosition.topEnd(end: -4, top: -8),
      child: FloatingActionButton(
        shape: const RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.black),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30.0),
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
          ),
        ),
        backgroundColor: Colors.white,
        heroTag: "mess",
        onPressed: () {
          Navigator.pushNamed(context, RoutePage.messagesPage);
        },
        tooltip: 'Message',
        child: SizedBox(
          height: 50,
          width: 50,
          child: Icon(
            Icons.markunread,
            color: val == 0 ? Colors.black : UIData.colorPrincipal,
          ),
        ),
      ),
    );
  }
}
