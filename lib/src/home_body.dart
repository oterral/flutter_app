import 'package:flutter/material.dart';
import 'search.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          color: Colors.amber[600],
          child: MapboxMap(
              accessToken:
                  "sk.eyJ1Ijoib3RlcnJhbCIsImEiOiJjbGF0ajRwcWowMWIzM25xcnB1M2lra3M2In0.79lPBtCYQAWhjOdElXixHw",
              initialCameraPosition:
                  const CameraPosition(target: LatLng(0.0, 0.0)),
              styleString:
                  'https://maps.style-dev.geops.io/styles/base_bright_v2/style.json')),
      const Search()
    ]);
  }
}
