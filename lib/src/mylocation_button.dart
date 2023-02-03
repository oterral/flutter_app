import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_model.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

// class MyLocationButton extends StatefulWidget {
//   const MyLocationButton({super.key});

//   @override
//   State<MyLocationButton> createState() => _State();
// }

class MyLocationButton extends StatelessWidget {
// class _State extends State<MyLocationButton> {
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
        onPressed: () async {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.location,
          ].request();
          if (statuses[Permission.location]!.isGranted) {
            app.onMyLocationPressed();
          } else {
            print("!!!!!!!!!!!!!! Location permission not granted");
          }
        },
        tooltip: 'Toggle my location',
        child: Icon(icon),
      );
    });
    ;
  }
}
