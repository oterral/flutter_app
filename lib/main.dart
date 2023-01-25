import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_model.dart';
import 'package:flutter_app/src/feedback_form.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppModel(),
      // child: const App(),
      // Bettre Feedback dosen't print the map in the screenshot
      child: BetterFeedback(
        theme: FeedbackThemeData(
          // background: Colors.grey,
          // feedbackSheetColor: Colors.grey[50]!,
          drawColors: [
            // Colors.red,
            Colors.green,
            // Colors.blue,
            Colors.yellow,
          ],
        ),
        mode: FeedbackMode.draw,
        feedbackBuilder: (context, onSubmit, scrollController) => FeedbackForm(
          onSubmit: onSubmit,
          scrollController: scrollController,
        ),
        child: const App(),
      ),
    ),
  );
}
