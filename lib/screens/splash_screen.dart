import 'package:expense/screens/home_page.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          context.watch<ExpenseViewModel>().initViewModel(),
          Future.delayed(const Duration(seconds: 2))
        ]),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            WidgetsBinding.instance!.addPostFrameCallback((_) =>
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage())));

            return Container();
          }
          return const Scaffold(
              body: Center(
                  child: Text(
            "Hang Tight...",
            style: TextStyle(fontSize: 30),
          )));
        });
  }
}
