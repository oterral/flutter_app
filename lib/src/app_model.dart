import 'dart:convert';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;

class AppModel extends ChangeNotifier {
  double x = 8.0;
  double y = 46.7;
  double z = 7.0;
  double popupAnchorX = 8.0;
  double popupPixelY = 46.7;
  MapboxMapController? mapCtrl;
  List<Map<String, dynamic>> viaPoints = [];
  Map<String, dynamic> route = {};
  Future<List<dynamic>> futureFeatures = Future(() => []);

  void fetchViaPoint(LatLng coordinates) async {
    final coord = [coordinates.latitude, coordinates.longitude].join(',');
    final url =
        'https://walking.geops.io/availableLevels?point=$coord&distance=0.006';
    print('################### fetchViaPoint');
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      removeRoute();
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final viaPoint = jsonDecode(response.body);
      print("Via point decoded json");
      print(viaPoint);
      if (viaPoints.length >= 2) {
        clearViaPoints();
      }
      addViaPoint(viaPoint);
      fetchRoute();
      notifyListeners();
      // } else {
      //   // If the server did not return a 200 OK response,
      //   // then throw an exception.
      //   throw Exception('Failed to load via point');
    }
  }

  void fetchRoute() async {
    if (viaPoints.length <= 1) {
      return;
    }
    List<String> coords = [];
    viaPoints.forEach((viaPoint) {
      List<dynamic> arr = viaPoint['geometry']['coordinates'];
      coords.add(arr.reversed.join(','));
    });
    final String via = coords.join('|');

    // rail
    // String url =
    //     "https://api.geops.io/routing/v1/?via=$via&mot=foot&resolve-hops=false&key=5cc87b12d7c5370001c1d655012b7edc8da1475084e49b84b6ba658e&elevation=0&interpolate_elevation=false&length=true&coord-radius=100.0&coord-punish=1000.0&barrierefrei=false";
    //foot
    String url =
        "https://api.geops.io/routing/v1/?via=$via&mot=foot&resolve-hops=false&key=5cc87b12d7c5370001c1d655012b7edc8da1475084e49b84b6ba658e&elevation=0&interpolate_elevation=false&length=true&coord-radius=100.0&coord-punish=1000.0&barrierefrei=false";

    print('################### fetchRoute');
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final route = jsonDecode(response.body);
      print("Route Decoded json");
      print(route);
      removeRoute();
      addRoute(route);

      notifyListeners();
      // } else {
      //   // If the server did not return a 200 OK response,
      //   // then throw an exception.
      //   throw Exception('Failed to load via point');
    }
  }

  void onMapCreated(MapboxMapController controller) {
    mapCtrl = controller;
  }

  void onStyleLoadedCallback() {
    //  Add source and layer to display the routing line
    Map<String, dynamic> emptyData = {
      "features": [],
      "type": 'FeatureCollection'
    };
    print('addsource');
    print(mapCtrl);
    mapCtrl!.addGeoJsonSource('route', emptyData);
    mapCtrl!.addLayer(
        'route',
        'route',
        const LineLayerProperties(
          lineOpacity: 0.6,
          lineColor: '#FF0000',
          lineWidth: 3,
        ),
        enableInteraction: false);

    // Add listener when we click a via point
    mapCtrl!.onCircleTapped.add(onViaPointTapped);
  }

  void onMapClick(Point<double> point, LatLng coordinates) async {
    print(point);
    print(coordinates);
    futureFeatures = Future(() => []);
    if (mapCtrl != null) {
      // print('################### queryRenderedFeastures');
      // futureFeatures = mapCtrl.queryRenderedFeatures(
      //     point, ["station_1x_rail", "station_1x_div", "station_2x_div"], null);
      // notifyListeners();

      fetchViaPoint(coordinates);
    }
  }

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void center(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;

    mapCtrl?.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(this.y, this.x), zoom: this.z)));

    // This call tells the widgets that are listening to this model to rebuild.
    // notifyListeners();
  }

  void addViaPoint(Map<String, dynamic> viaPoint) async {
    print('################### addViaPoint');
    print(viaPoint);
    viaPoints.add(viaPoint);
    final circle = await mapCtrl!.addCircle(
      CircleOptions(
          geometry: LatLng(
            viaPoint['geometry']['coordinates'][1],
            viaPoint['geometry']['coordinates'][0],
          ),
          circleColor: "#FF0000",
          circleRadius: 10),
    );
    viaPoint['circle'] = circle;
  }

  void removeViaPoint(Map<String, dynamic> viaPoint) {
    print('################### removeViaPoint');
    print(viaPoint);
    if (viaPoint['circle'] != null) {
      mapCtrl!.removeCircle(viaPoint['circle']);
    }
    for (var i = viaPoints.length - 1; i >= 0; i--) {
      if (viaPoints[i] == viaPoint) {
        viaPoints.remove(i);
        break;
      }
    }
  }

  void clearViaPoints() {
    mapCtrl!.clearCircles();
    viaPoints = [];
  }

  void onViaPointTapped(Circle circle) {
    Map<String, dynamic> viaPoint =
        viaPoints.firstWhere((element) => element['circle'] == circle);
    print("###### viaPoint tapped");
    print(viaPoint);
    print(circle);
  }

  void onRouteTapped(Line line) {
    print("###### route tapped");
    print(line);
  }

  // Add the results of the routing between viaPoints on the map.
  void addRoute(Map<String, dynamic> rte) {
    print('################### addRoute');
    route = rte;
    print(route);
    mapCtrl!.setGeoJsonSource('route', route);
  }

  // Remove the results of the routing between viaPoints from the map
  void removeRoute() {
    print('################### removeRoute');
    mapCtrl!.setGeoJsonSource('route', {
      "features": [],
      "type": "FeatureCollection",
    });
  }
}
