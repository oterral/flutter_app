import 'package:flutter/cupertino.dart';

class AppModel extends ChangeNotifier {
  double x = 0.0;
  double y = 0.0;

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void zoom(double x, double y) {
    this.x = x;
    this.y = y;

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
