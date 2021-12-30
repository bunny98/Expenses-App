import 'package:expense/screens/splash_screen.dart';
import 'package:expense/utils/my_scroll_behaviour.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ExpenseViewModel()),
    ],
    child: const MyApp(),
  ));
}

const int _blackPrimaryValue = 0xFF000000;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          _blackPrimaryValue,
          <int, Color>{
            50: Color(0xFF000000),
            100: Color(0xFF000000),
            200: Color(0xFF000000),
            300: Color(0xFF000000),
            400: Color(0xFF000000),
            500: Color(_blackPrimaryValue),
            600: Color(0xFF000000),
            700: Color(0xFF000000),
            800: Color(0xFF000000),
            900: Color(0xFF000000),
          },
        ),
      ),
      builder: (context, child) => ScrollConfiguration(
        behavior: MyBehavior(),
        child: child!,
      ),
      home: SplashScreen(),
    );
  }
}
