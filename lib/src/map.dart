import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MbMap extends StatefulWidget {
  const MbMap({super.key});

  @override
  State<MbMap> createState() => _MapState();
}

class _MapState extends State<MbMap> {
  @override
  Widget build(BuildContext context) {
    return MapboxMap(
        accessToken:
            "sk.eyJ1Ijoib3RlcnJhbCIsImEiOiJjbGF0ajRwcWowMWIzM25xcnB1M2lra3M2In0.79lPBtCYQAWhjOdElXixHw",
        initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
        styleString:
            'https://maps.style-dev.geops.io/styles/base_bright_v2/style.json');
  }
}
