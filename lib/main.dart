import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// https://flutter.dev/docs/cookbook/networking/fetch-data
Future<Compliment> fetchCompliment() async {
  final response = await http.get('https://complimentr.com/api');

  if (response.statusCode == 200) {
    return Compliment.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

class Compliment {
  final String compliment;

  Compliment({this.compliment});

  factory Compliment.fromJson(Map<String, dynamic> json) {
    return Compliment(compliment: json['compliment']);
  }
}

class ComplimentCard extends StatelessWidget {
  final String compliment;

  ComplimentCard(this.compliment) : super();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      onTap: () {
        print('Card tapped.');
      },
      splashColor: Colors.blue.withAlpha(30),
      child: Container(
          width: 400, height: 300, child: Center(child: Text(compliment))),
    ));
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  Future<Compliment> futureCompliment;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    futureCompliment = fetchCompliment();
    _controller = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this,
        lowerBound: 0.0,
        upperBound: 1.0);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void refreshCompliment() {
    setState(() {
      // TODO: Fix Animation
      _controller
          .repeat(period: Duration(seconds: 1))
          .then((_) => _controller.reset());
      futureCompliment = fetchCompliment();
    });
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
          backgroundColor: Colors.indigo,
          body: Center(
            child: FutureBuilder<Compliment>(
              future: futureCompliment,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ComplimentCard(snapshot.data.compliment);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            splashColor: Colors.pink,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            onPressed: refreshCompliment,
            child: RotationTransition(
              child: Icon(Icons.refresh),
              alignment: Alignment.center,
              turns: _controller,
            ),
          )),
    );
  }
}
