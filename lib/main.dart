import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// https://flutter.dev/docs/cookbook/networking/fetch-data
Future<Compliment> fetchCompliment() async {
  final response =
      await http.get('https://complimentr.com/api');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Compliment.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Compliment {
  final String compliment;

  Compliment({this.compliment});

  factory Compliment.fromJson(Map<String, dynamic>json) {
    return Compliment(
      compliment: json['compliment']
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Compliment> futureCompliment;

  @override
  void initState() {
    super.initState();
    futureCompliment = fetchCompliment();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complidence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Complidence'),
        ),
        body: Center(
          child: FutureBuilder<Compliment>(
            future: futureCompliment,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.compliment);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
