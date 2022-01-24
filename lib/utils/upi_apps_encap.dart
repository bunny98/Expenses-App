class UpiAppsEncapsulator<T> {
  late List<T> _upiAppsList;
  late T? _chosenUpiApp;

  UpiAppsEncapsulator({required List<T> apps}) {
    _upiAppsList = apps;
    _chosenUpiApp = apps.isNotEmpty ? apps.first : null;
  }

  List<T> getAppsList() => _upiAppsList;

  void chooseUpiApp(T upiApp) {
    _chosenUpiApp = upiApp;
  }

  T? getChosenUpiApp() => _chosenUpiApp;
}
