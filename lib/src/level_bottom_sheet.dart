import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app/src/app_model.dart';
import 'package:flutter_app/src/level_select.dart';
import 'package:flutter_app/src/mylocation_button.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

class LevelBottomSheet extends StatefulWidget {
  const LevelBottomSheet({super.key});

  @override
  State<LevelBottomSheet> createState() => _LevelBottomSheetState();
}

class _LevelBottomSheetState extends State<LevelBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, app, child) {
      // Timer(Duration(milliseconds: 1000), () => app.show());

      return DraggableScrollableSheet(
        // controller: app.draggableScrollableController,
        initialChildSize: app.selectedViaPoint == null ? 0 : 0.3,
        minChildSize: app.selectedViaPoint == null ? 0 : 0.1,
        maxChildSize: 0.5,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            color: Colors.white,
            child: LevelSelect(
              scrollController,
            ),
          );
        },
      );
    });
  }
}
