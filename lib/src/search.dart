import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Stop {
  final String name;
  final List<double> coordinates;

  const Stop({
    required this.name,
    required this.coordinates,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      name: json['properties']['name'],
      coordinates: json['geometry']['coordinates'].cast<double>(),
    );
  }
}

Future<List<Stop>> fetchStops(String q) async {
  final response = await http.get(Uri.parse(
      'https://api.geops.io/stops/v1/?&q=$q&key=5cc87b12d7c5370001c1d6555b11c9605dc84a90b098a4c3bb50eb0a&limit=50'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<Stop> stops = [];
    final featureColl = jsonDecode(response.body);
    List<dynamic> features = featureColl['features'];
    for (var feature in features) //for..in loop to print list element
    {
      var stop = Stop.fromJson(feature);
      print(stop.name);
      stops.add(stop); //to print the number
    }
    print(stops);
    return stops;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    // throw Exception('Failed to load stops');
    return [];
  }
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late TextEditingController _controller;
  late Future<List<Stop>> futureStops = Future(() => []);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          // width: 300.0,
          height: 100.0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Colors.white,
          child: Center(
            child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Search stations',
                  hintText: 'Bern, Lausanne ...',
                  hintStyle: TextStyle(
                    color: Colors.blueGrey[400],
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                onSubmitted: (String value) async {
                  print('CHANGED');
                  print(value);
                  setState(() {
                    futureStops = fetchStops(value);
                  });
                }
                //   await fetchStops<void>(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: const Text('Thanks!'),
                //         content: Text(
                //             'You typed "$value", which has length ${value.characters.length}.'),
                //         actions: <Widget>[
                //           TextButton(
                //             onPressed: () {
                //               Navigator.pop(context);
                //             },
                //             child: const Text('OK'),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // }
                ),
          )),
      Container(
        margin: const EdgeInsets.only(top: 99.0),
        color: Colors.white,
        child: FutureBuilder<List<Stop>>(
          future: futureStops,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (data != null && data.isNotEmpty) {
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          margin: const EdgeInsets.all(0),
                          padding: const EdgeInsets.all(8),
                          height: 50,
                          child: ListTile(
                              onTap: () {
                                print(data[index].name);
                                print(data[index].coordinates.toString());
                                setState(() {
                                  futureStops = Future(() => []);
                                  _controller.text = data[index].name;
                                });
                              },
                              title: Text(data[index].name)));
                    });
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            }
            return const Text('');
          },
        ),
      )
    ]);
  }
}
