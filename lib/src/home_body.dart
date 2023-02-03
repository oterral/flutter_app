import 'package:flutter/material.dart';
import 'package:flutter_app/src/map.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: const [
      MbMap(),
      //, Search()
    ]);
  }
}
