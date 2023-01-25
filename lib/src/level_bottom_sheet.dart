import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_model.dart';
import 'package:flutter_app/src/level_select.dart';
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
      return DraggableScrollableSheet(
        initialChildSize: app.selectedViaPoint == null ? 0 : 0.3,
        minChildSize: app.selectedViaPoint == null ? 0 : 0.1,
        maxChildSize: 0.5,
        builder: (BuildContext context, ScrollController scrollController) {
          if (app.selectedViaPoint == null) {
            return const Text('');
          }
          return Container(
            color: Colors.white,
            child: const LevelSelect(),
          );
        },
      );
    });
  }
}
