import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_model.dart';
import 'package:provider/provider.dart';

class MyLocationButton extends StatefulWidget {
  const MyLocationButton({super.key});

  @override
  State<MyLocationButton> createState() => _State();
}

class _State extends State<MyLocationButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, app, child) {
      IconData icon;
      Color? color;
      // Theme.of(context).buttonTheme.colorScheme?.tertiary

      if (app.myLocationEnabled) {
        color = Theme.of(context).toggleableActiveColor;
        icon = Icons.location_disabled;
      } else {
        icon = Icons.my_location;
      }
      return FloatingActionButton(
        backgroundColor: color,
        onPressed: () {
          app.onMyLocationPressed();
        },
        tooltip: 'Toggle my location',
        child: Icon(icon),
      );
    });
    ;
  }
}
