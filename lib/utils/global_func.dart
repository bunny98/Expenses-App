import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<void> showToast(String msg) async {
  await Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.black,
      fontSize: 16.0);
}

Future<bool> showConfirmActionDialog(
    {required String msg, required BuildContext context}) async {
  bool _res = false;
  await Alert(
    context: context,
    type: AlertType.warning,
    title: "ALERT",
    desc: msg,
    buttons: [
      DialogButton(
        child: const Text(
          "Yes",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          _res = true;
          Navigator.pop(context);
        },
        color: const Color.fromRGBO(0, 179, 134, 1.0),
      ),
      DialogButton(
        child: const Text(
          "No",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          _res = false;
          Navigator.pop(context);
        },
        gradient: const LinearGradient(colors: [
          Color.fromRGBO(116, 116, 191, 1.0),
          Color.fromRGBO(52, 138, 199, 1.0)
        ]),
      )
    ],
  ).show();
  return _res;
}
