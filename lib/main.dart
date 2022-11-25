import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_model.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppModel(),
      child: const App(),
    ),
  );
}
