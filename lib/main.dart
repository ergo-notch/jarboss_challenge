import 'package:flutter/material.dart';
import 'package:jarboss_challenge/core/core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.lightGreenAccent,
          appBarTheme: AppBarTheme(color: Colors.deepPurple),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.lightGreenAccent,
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}
