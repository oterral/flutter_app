import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';

const apiKey = "5cc87b12d7c5370001c1d655012b7edc8da1475084e49b84b6ba658e";

Future<Map<String, dynamic>?> fetchViaPoint(LatLng coordinates) async {
  final coord = [coordinates.latitude, coordinates.longitude].join(',');
  final url =
      'https://walking.geops.io/availableLevels?point=$coord&distance=0.006';
  print('################### fetchViaPoint');
  print(url);
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final viaPoint = jsonDecode(response.body);
    print(viaPoint);
    return viaPoint;
    // } else {
    //   // If the server did not return a 200 OK response,
    //   // then throw an exception.
    //   throw Exception('Failed to load via point');
  }
  return null;
}

Future<Map<String, dynamic>?> fetchRoute(viaPoints) async {
  if (viaPoints.length <= 1) {
    return null;
  }
  List<String> coords = [];
  viaPoints.forEach((viaPoint) {
    List<dynamic> arr = viaPoint['geometry']['coordinates'];
    String? level = viaPoint['level'];
    if (level != null) {
      level = '\$$level';
    } else {
      level = '';
    }

    coords.add(arr.reversed.join(',') + level);
  });
  final String via = coords.join('|');

  // rail
  // String url =
  //     "https://api.geops.io/routing/v1/?via=$via&mot=foot&resolve-hops=false&key=5cc87b12d7c5370001c1d655012b7edc8da1475084e49b84b6ba658e&elevation=0&interpolate_elevation=false&length=true&coord-radius=100.0&coord-punish=1000.0&barrierefrei=false";
  //foot
  String url =
      "https://api.geops.io/routing/v1/?via=$via&mot=foot&resolve-hops=false&key=$apiKey&elevation=0&interpolate_elevation=false&length=true&coord-radius=100.0&coord-punish=1000.0&barrierefrei=false";

  print('################### fetchRoute');
  print(url);
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final route = jsonDecode(response.body);
    print(route);
    return route;
    // } else {
    //   // If the server did not return a 200 OK response,
    //   // then throw an exception.
    //   throw Exception('Failed to load via point');
  }
  return null;
}
