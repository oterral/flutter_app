import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter_app/src/utils.dart';
import 'package:flutter_app/src/level_select.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class AppModel extends ChangeNotifier {
  // Swiss
  // double x = 8.0;
  // double y = 46.7;
  // double z = 7.0;

  // Bern Station
  double x = 7.439938;
  double y = 46.948862;
  double z = 18.0;

  double popupAnchorX = 8.0;
  double popupPixelY = 46.7;
  MapboxMapController? mapCtrl;
  final mapKey = GlobalKey();
  List<Map<String, dynamic>> viaPoints = [];
  Map<String, dynamic>? route;
  Future<List<dynamic>> futureFeatures = Future(() => []);
  Map<String, dynamic>? selectedViaPoint;
  bool myLocationEnabled = false;
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  /* *
   * 
   * Initialization of the map
   * 
   * */

  void onMapCreated(MapboxMapController controller) {
    mapCtrl = controller;
  }

  void onStyleLoadedCallback() async {
    //  Add source and layer to display the routing line
    mapCtrl!.addGeoJsonSource('route', buildFeatureCollection([]));
    mapCtrl!.addLayer(
        'route',
        'route',
        const LineLayerProperties(
          lineOpacity: 0.6,
          lineColor: '#00FF00',
          lineWidth: 3,
        ), // Last style of travic_v2, without this the oute is on top of circles
        belowLayerId: 'loom_station_end',
        enableInteraction: false);
  }

  /* *
   * 
   * User interaction management
   * 
   * */

  void onMapClick(Point<double> point, LatLng coordinates, context) async {
    futureFeatures = Future(() => []);

    // if (viaPoints.length == 1) {
    //   selectedViaPoint = null;
    //   updateViaPoints();
    //   notifyListeners();
    // } else
    if (viaPoints.length == 2) {
      clearMap();
      notifyListeners();
    } else if (mapCtrl != null) {
      selectedViaPoint = null;
      // Clear the display
      clearRoute();
      notifyListeners();

      // Fetch then add via point
      Map<String, dynamic>? viaPoint = await fetchViaPoint(coordinates);
      if (viaPoint != null) {
        addViaPoint(viaPoint);
      }
      notifyListeners();

      // Fetch then add route between via points
      updateRoute();
      notifyListeners();
    }
    showLevelsModal(context);
  }

  void onViaPointTapped(viaPoint, context) {
    print("###### viaPoint tapped");
    print(viaPoint);
    List<dynamic> availableLevels = viaPoint["properties"]["availableLevels"];
    if (availableLevels.isNotEmpty) {
      selectedViaPoint = viaPoint;
      updateViaPoints();
    }
    notifyListeners();
    showLevelsModal(context);
  }

  void onCircleTapped(Circle circle, context) {
    Map<String, dynamic> viaPoint =
        viaPoints.firstWhere((element) => element['circle'] == circle);
    print("###### viaPoint circle tapped");
    onViaPointTapped(viaPoint, context);
  }

  void onSymbolTapped(Symbol text, context) async {
    Map<String, dynamic> viaPoint =
        viaPoints.firstWhere((element) => element['text'] == text);
    print("###### viaPoint text tapped");
    onViaPointTapped(viaPoint, context);
  }

  void onRouteTapped(Line line) {
    print("###### route tapped");
    print(line);
  }

  void onSelectViaPointLevel(String? level) async {
    if (selectedViaPoint != null) {
      selectedViaPoint?["level"] = level;
      updateViaPoints();
      updateRoute();
      notifyListeners();
    }
  }

  void onMyLocationPressed() {
    myLocationEnabled = !myLocationEnabled;
    notifyListeners();
  }

  /* *
   * 
   * Map management
   * 
   * */

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

  /* *
   * 
   * Via points display management
   * 
   * */

  void addViaPoint(Map<String, dynamic> viaPoint) async {
    if (viaPoints.length >= 2) {
      clearViaPoints();
    }
    print('################### addViaPoint');
    print(viaPoint);
    viaPoints.add(viaPoint);
    selectedViaPoint = viaPoint;
    updateViaPoints();
  }

  void removeViaPoint(Map<String, dynamic> viaPoint) {
    print('################### removeViaPoint');
    print(viaPoint);
    viaPoints.removeWhere((element) => element == viaPoint);
    updateViaPoints();
  }

  void clearViaPoints() {
    mapCtrl!.clearCircles();
    mapCtrl!.clearSymbols();
    viaPoints = [];
    selectedViaPoint = null;
  }

  // Update style of all via points depending of the current status of the app
  void updateViaPoints() async {
    for (var viaPoint in viaPoints) {
      LatLng geometry = LatLng(
        viaPoint['geometry']['coordinates'][1],
        viaPoint['geometry']['coordinates'][0],
      );

      // Define which level to use
      String? selectedLevel = viaPoint["level"];

      if (selectedLevel == null) {
        List<dynamic> levels = viaPoint["properties"]["availableLevels"];
        int level0 =
            levels.firstWhere((element) => element == 0, orElse: () => -1);
        if (level0 != -1) {
          selectedLevel = "0";
        } else if (levels.isNotEmpty) {
          selectedLevel = levels.last.toString();
        }
        viaPoint["level"] = selectedLevel;
      }

      // Define circle style
      CircleOptions circleOptions;
      if (viaPoint == selectedViaPoint) {
        circleOptions = CircleOptions(
            geometry: geometry,
            circleColor: "#FF0000",
            circleOpacity: 1,
            circleRadius: 20);
      } else {
        circleOptions = CircleOptions(
            geometry: geometry,
            circleColor: "#FF0000",
            circleOpacity: 0.5,
            circleRadius: 15);
      }

      Circle? circle = viaPoint['circle'];
      if (circle != null) {
        await mapCtrl?.updateCircle(circle, circleOptions);
      } else {
        viaPoint['circle'] = await mapCtrl!.addCircle(circleOptions);
      }

      // Define text style
      final symbolOptions = SymbolOptions(
          geometry: geometry, textField: selectedLevel, textColor: '#FFFFFF');
      Symbol? text = viaPoint['text'];
      if (text != null) {
        await mapCtrl?.updateSymbol(text, symbolOptions);
      } else {
        viaPoint['text'] = await mapCtrl!.addSymbol(symbolOptions);
      }
    }
  }

  /* *
   * 
   * Route display management
   * 
   * */

  // Add the results of the routing between viaPoints on the map.
  void addRoute(Map<String, dynamic>? newRoute) {
    route = newRoute;
    mapCtrl!.setGeoJsonSource('route', route!);
  }

  // Remove the results of the routing between viaPoints from the map
  void removeRoute() {
    mapCtrl!.setGeoJsonSource('route', {
      "features": [],
      "type": "FeatureCollection",
    });
    route = null;
  }

  void clearRoute() {
    removeRoute();
  }

  // Fetch then add route between via points
  void updateRoute() async {
    if (route != null) {
      removeRoute();
    }
    // Fetch then add route between via points
    Map<String, dynamic>? newRoute = await fetchRoute(viaPoints);
    if (newRoute != null) {
      addRoute(newRoute);
    }
  }

  void clearMap() {
    clearViaPoints();
    clearRoute();
    notifyListeners();
  }

  /* *
   *
   * Bottom sheet management
   * 
   * */
  void showLevelsModal(context) {
    if (selectedViaPoint == null) {
      return;
    }

    if (selectedViaPoint!["properties"]["availableLevels"].length <= 1) {
      return;
    }

    print("nb levels");
    print(selectedViaPoint!["properties"]["availableLevels"]);

    showSBBModalSheet<String>(
      context: context,
      title: 'Choose a floor',
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          sbbDefaultSpacing,
          0.0,
          sbbDefaultSpacing,
          sbbDefaultSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              height: 200,
              child: LevelSelect(),
            )
          ],
        ),
      ),
    ).then((result) {
      selectedViaPoint = null;
      updateViaPoints();
      notifyListeners();
    });
  }
}
