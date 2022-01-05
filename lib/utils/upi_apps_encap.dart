import 'package:upi_india/upi_app.dart';

class UpiAppsEncapsulator {
  late List<UpiApp> _upiAppsList;
  late UpiApp? _chosenUpiApp;

  UpiAppsEncapsulator({required List<UpiApp> apps}) {
    _upiAppsList = apps;
    _chosenUpiApp = apps.isNotEmpty ? apps.first : null;
  }

  List<UpiApp> getAppsList() => _upiAppsList;

  void chooseUpiApp(UpiApp upiApp) {
    _chosenUpiApp = upiApp;
  }

  UpiApp? getChosenUpiApp() => _chosenUpiApp;
}
