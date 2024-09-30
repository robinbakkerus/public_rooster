import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:public_rooster/firebase_options.dart';
import 'package:public_rooster/page/view_spreadsheet_page.dart';
import 'package:public_rooster/util/app_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TargetPlatform platform = AppHelper.instance.getPlatform();
    bool isWindows = platform == TargetPlatform.windows;
    AppHelper.instance.setupLocale(context);
    return MaterialApp(
      title: 'Lonu public trainingschemas',
      scrollBehavior: isWindows
          ? const MaterialScrollBehavior()
              .copyWith(dragDevices: {PointerDeviceKind.mouse})
          : const MaterialScrollBehavior()
              .copyWith(dragDevices: {PointerDeviceKind.touch}),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const ViewSchemaPage(),
    );
  }
}
