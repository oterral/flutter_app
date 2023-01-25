import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proj4dart/proj4dart.dart';

const apiKey = "5cc87b12d7c5370001c1d655012b7edc8da1475084e49b84b6ba658e";

Future<Map<String, dynamic>?> fetchViaPoint(LatLng coordinates) async {
  final coord = [coordinates.latitude, coordinates.longitude].join(',');
  final url =
      'https://walking.geops.io/availableLevels?point=$coord&distance=0.003';

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

Point toLonLat(Point point) {
  return Projection.GOOGLE.transform(Projection.WGS84, point);
}

Point fromLonLat(Point point) {
  return Projection.WGS84.transform(Projection.GOOGLE, point);
}

// Returns the routing demo url equivalent of the current state
// https://routing-demo.geops.io/?floorInfo=2,-1&mot=foot&resolve-hops=false&via=7.43961,46.94876%7C7.44027,46.94898&x=828171.6&y=5933746.85&z=20.4
String getRoutingDemoUrl(
    List<Map<String, dynamic>> viaPoints, double x, double y, double z) {
  // x,y
  Point center = fromLonLat(Point.fromArray([x, y]));

  List<String> params = [
    "mot=foot",
    "resolve-hops=false",
    "x=${center.x.toString()}",
    "y=${center.y.toString()}",
    "z=${(z + 1).toString()}",
  ];

  if (viaPoints.isNotEmpty) {
    List<String> vias = [];
    List<String> floorInfos = [];

    for (var viaPoint in viaPoints) {
      {
        vias.add(viaPoint["geometry"]["coordinates"].join(','));

        if (viaPoint["level"] == null) {
          floorInfos.add("0");
        } else {
          floorInfos.add(viaPoint["level"]);
        }
      }
    }

    if (vias.isNotEmpty) {
      params.add("via=${vias.join('|')}");
    }
    if (floorInfos.isNotEmpty) {
      params.add("floorInfo=${floorInfos.join(',')}");
    }
  }

  return "https://routing-demo.geops.io/?${params.join('&')}";
}

Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
  final Directory output = await getTemporaryDirectory();
  final String screenshotFilePath = '${output.path}/feedback.png';
  final File screenshotFile = File(screenshotFilePath);
  await screenshotFile.writeAsBytes(feedbackScreenshot);
  return screenshotFilePath;
}
