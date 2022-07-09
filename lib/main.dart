import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Networking Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Flutter Networking Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class StateCovid {
  final String state;
  final int cases;
  final int deaths;
  final int active;
  final int population;

  const StateCovid(
      {required this.state,
      required this.cases,
      required this.deaths,
      required this.active,
      required this.population});

  factory StateCovid.fromJson(Map<String, dynamic> json) {
    return StateCovid(
      state: json['state'],
      cases: json['cases'],
      deaths: json['deaths'],
      active: json['active'],
      population: json['population'],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List> fetchCovid() async {
    final response = await http
        .get(Uri.parse('https://disease.sh/v3/covid-19/states?sort=cases'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final states = json.map((state) => StateCovid.fromJson(state)).toList();
      return states;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder(
              future: fetchCovid(),
              builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: _createColumns(),
                        rows: _createRows(snapshot.data),
                      ));
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                return const CircularProgressIndicator();
              }),
        ));
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(
          label: Text('State', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Cases', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Deaths', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Active', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Population',
              style: TextStyle(fontWeight: FontWeight.bold))),
    ];
  }

  _createRows(List? data) {
    NumberFormat format = NumberFormat.decimalPattern('en_US');
    return data
        ?.map((state) => DataRow(cells: [
              DataCell(Text(state.state)),
              DataCell(Text(format.format(state.cases))),
              DataCell(Text(format.format(state.deaths))),
              DataCell(Text(format.format(state.active))),
              DataCell(Text(format.format(state.population))),
            ]))
        .toList();
  }
}
