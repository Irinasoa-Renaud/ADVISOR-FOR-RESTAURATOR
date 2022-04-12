import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  String name;
  int age;
  User(this.name, this.age);
  factory User.fromJson(dynamic json) {
    return User(json['name'] as String, json['age'] as int);
  }
  @override
  String toString() {
    return '{ ${this.name}, ${this.age} }';
  }
}

class Tag {
  String name;
  int quantity;
  Tag(this.name, this.quantity);
  factory Tag.fromJson(dynamic json) {
    return Tag(json['name'] as String, json['quantity'] as int);
  }
  @override
  String toString() {
    return '{ ${this.name}, ${this.quantity} }';
  }
}

class Tutorial {
  String title;
  String description;
  User author;
  List<Tag>? tags;
  Tutorial(this.title, this.description, this.author, [this.tags]);
  factory Tutorial.fromJson(dynamic json) {
    if (json['tags'] != null) {
      var tagObjsJson = json['tags'] as List;
      List<Tag> _tags =
          tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();
      return Tutorial(json['title'] as String, json['description'] as String,
          User.fromJson(json['author']), _tags);
    } else {
      return Tutorial(json['title'] as String, json['description'] as String,
          User.fromJson(json['author']));
    }
  }
  @override
  String toString() {
    return '{ ${this.title}, ${this.description}, ${this.author}, ${this.tags} }';
  }
}

main() async {
  var url = Uri.parse('https://api-advisor.voirlemenu.fr/login');
  // var url = Uri.parse('https://api-advisor.voirlemenu.fr/commands');
  // var url = Uri.parse(
  //     'https://api-advisor.voirlemenu.fr/commands?type=delivery&filter={"restaurant":"61e18c29669bbb405a3d2d8b"}&"access_token"="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYxZDgzODhiY2NkOWIyMDAzMWQ4YTZlMyIsImlhdCI6MTY0NjMyNzQ1NiwiZXhwIjoxNjQ2MzM4MjU2fQ.Dc-2hbNqbfIjFJTWYxwjdHLFpvqv_hFyGK0WAINW6tA"');

  try {
    //   var response = await http.get(url, headers: {
    //     "access_token":
    //         "eyJhbGciOiJIUzI1NsiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYxZDgzODhiY2NkOWIyMDAzMWQ4YTZlMyIsImlhdCI6MTY0NjMyNzQ1NiwiZXhwIjoxNjQ2MzM4MjU2fQ.Dc-2hbNqbfIjFJTWYxwjdHLFpvqv_hFyGK0WAINW6tA",
    //     "refresh_token":
    //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYxZDgzODhiY2NkOWIyMDAzMWQ4YTZlMyIsImlhdCI6MTY0NjMyNzQ1Nn0.ON0cdiJO8nkYqX6mggOTjbfNlaR8rvfe7oejMWmJnaw",
    //   });

    // var response = await http.post(url, headers: {
    //   "access_token":
    //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYxZDgzODhiY2NkOWIyMDAzMWQ4YTZlMyIsImlhdCI6MTY0NjMyNzQ1NiwiZXhwIjoxNjQ2MzM4MjU2fQ.Dc-2hbNqbfIjFJTWYxwjdHLFpvqv_hFyGK0WAINW6tA",
    //   "refresh_token":
    //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYxZDgzODhiY2NkOWIyMDAzMWQ4YTZlMyIsImlhdCI6MTY0NjMyNzQ1Nn0.ON0cdiJO8nkYqX6mggOTjbfNlaR8rvfe7oejMWmJnaw",
    // }, body: {
    //   'type': 'delivery',
    //   'filter': '{"restaurant":"61e18c29669bbb405a3d2d8b"}'
    // });

    var response = await http.post(url,
        body: {'login': 'adminGastro@admin.com', 'password': '123456789'});
    print(response.body);
    var jsonData = json.decode(response.body);
    print(jsonData);
  } catch (e) {
    print("error $e");
  }
  String complexText =
      '{"title": "Dart Tutorial", "description": "Way to parse Json", "author": {"name": "bezkoder", "age": 30}, "tags": [{"name": "dart", "quantity": 12}, {"name": "flutter", "quantity": 25}]}';
  Tutorial complexTutorial = Tutorial.fromJson(jsonDecode(complexText));
  print(complexTutorial.description);
  runApp(Aps(
    val: complexTutorial.author.name,
  ));
}

class Aps extends StatefulWidget {
  final String val;
  const Aps({Key? key, required this.val}) : super(key: key);

  @override
  _ApsState createState() => _ApsState();
}

class _ApsState extends State<Aps> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.open_in_browser),
            title: const Text("test.dart"),
          ),
          floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.coronavirus_outlined), onPressed: () {}),
          body: Center(
            child: Text(widget.val),
          ),
        ));
  }
}
