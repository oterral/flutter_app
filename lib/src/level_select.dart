import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_model.dart';
import 'package:provider/provider.dart';

class LevelSelect extends StatefulWidget {
  final ScrollController scrollController;

  const LevelSelect(this.scrollController, {super.key});

  @override
  State<LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelect> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, app, child) {
      print('################### app.selectedViaPoint');
      print(app.selectedViaPoint);

      Map<String, dynamic>? viaPoint = app.selectedViaPoint;

      if (viaPoint == null) {
        return const Text('');
      }
      String? selectedLevel = viaPoint["level"];
      List<dynamic> availableLevels = viaPoint["properties"]["availableLevels"];

      if (availableLevels.isEmpty || selectedLevel == null) {
        return const Text('');
      }
      return ListView.builder(
          controller: widget.scrollController,
          itemCount: availableLevels.length,
          itemBuilder: (BuildContext context, int index) {
            // var text = jsonEncode(data[index]);
            // JsonEncoder encoder = const JsonEncoder.withIndent('  ');
            // String prettyprint = encoder.convert(data[index]);
            dynamic value = availableLevels[index].toString();
            return Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(8),
                child: ListTile(
                    onTap: () {
                      print("############## click available level");
                      print(value);
                      // app.selectAvilableLevel
                      app.onSelectViaPointLevel(value);
                    },
                    title: Text(value),
                    leading: Radio<String>(
                        value: value,
                        groupValue: selectedLevel,
                        onChanged: (String? value) {
                          app.onSelectViaPointLevel(value);
                        })));
          });
    });
  }
}
