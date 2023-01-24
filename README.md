# flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Publish a test version on Google Play

- Sign the app following these [instructions](https://docs.flutter.dev/deployment/android#signing-the-app)

- Make sure the verion number is correct in pubspec.yaml, you have to increase the number after the `+` manually.

- Build the app:
  
```bash
flutter clean
flutter build appbundle
```

- Connect to [Google Play Console](https://play.google.com/console/) using geops.spatial.web account (find credentials in keepass).

- Create a new release and/or upload the new bundle in Tests -> Interner Test

- Add email of allowed testers in [Tester tab](https://play.google.com/console/u/0/developers/7798423032686463319/app/4973663387630397586/tracks/internal-testing?tab=testers)

- At the bottom of tester tab, copy the link for tester.

- Send the link to the testers or create a qrcode (using online converter or with chrome right-click-> create a qrcode) and send them the qrcode image. Qrcode could be copied in der JIRA ticket for example.

- If testers have installed the app they will receive automatically the new updates of this release
