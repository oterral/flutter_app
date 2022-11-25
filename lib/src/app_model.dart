import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class AppModel extends ChangeNotifier {
  double x = 8.0;
  double y = 46.7;
  double z = 7.0;
  double popupAnchorX = 8.0;
  double popupPixelY = 46.7;
  Future<List<dynamic>> futureFeatures = Future(() => []);
  MapboxMapController? mapCtrl;

  void onMapClick(point, coordinates) {
    print('CLick');
    print(point);
    print(coordinates);
    futureFeatures = Future(() => []);

    final mapCtrl = this.mapCtrl;
    if (mapCtrl != null) {
      print('################### queryRenderedFeatures');
      futureFeatures = mapCtrl.queryRenderedFeatures(
          point, ["station_1x_rail", "station_1x_div", "station_2x_div"], null);
      notifyListeners();
    }
  }

  void setMapController(mapCtrl) {
    this.mapCtrl = mapCtrl;
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
}
