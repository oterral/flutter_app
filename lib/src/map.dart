import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_model.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:proj4dart/proj4dart.dart';
import 'package:provider/provider.dart';

class MbMap extends StatefulWidget {
  const MbMap({super.key});

  @override
  State<MbMap> createState() => _MapState();
}

class _MapState extends State<MbMap> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, app, child) {
      double x = app.x;
      double y = app.y;
      // var center3857 = Point(x: x, y: y);
      // var epsg3857ToEpsg4326 = ProjectionTuple(
      //   // Use built-in projection
      //   fromProj: Projection.get('EPSG:3857')!,
      //   // Define custom projection
      //   toProj: Projection.get('EPSG:4326')!,
      // );
      // var center4326 = epsg3857ToEpsg4326.forward(center3857);
      print(x);
      print(y);
      print(app.z);
      // print(center4326.x);
      // print(center4326.y);
      return Stack(children: [
        MapboxMap(
          accessToken:
              "sk.eyJ1Ijoib3RlcnJhbCIsImEiOiJjbGF0ajRwcWowMWIzM25xcnB1M2lra3M2In0.79lPBtCYQAWhjOdElXixHw",
          initialCameraPosition:
              CameraPosition(target: LatLng(app.y, app.x), zoom: app.z),
          styleString:
              'https://maps.style-dev.geops.io/styles/base_bright_v2/style.json',
          onMapCreated: (controller) {
            print("@@@@@@@@@@@@@ onMapCreated");
            app.setMapController(controller);
          },
          onMapClick: (point, coordinates) {
            // ignore: avoid_print
            print("@@@@@@@@@@@@@ onMapClick");
            app.onMapClick(point, coordinates);
          },
        ),
        Container(
          margin: const EdgeInsets.only(top: 600.0),
          color: Colors.white,
          child: FutureBuilder<List<dynamic>>(
            future: app.futureFeatures,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (data != null && data.isNotEmpty) {
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        // var text = jsonEncode(data[index]);
                        JsonEncoder encoder =
                            const JsonEncoder.withIndent('  ');
                        String prettyprint = encoder.convert(data[index]);
                        return Container(
                            margin: const EdgeInsets.all(0),
                            padding: const EdgeInsets.all(8),
                            child: ListTile(
                                onTap: () {
                                  print(prettyprint);
                                },
                                title: Text(prettyprint)));
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
    });
  }
}
