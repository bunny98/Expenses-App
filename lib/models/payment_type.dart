class PaymentTypes {
  static late final Set<String> _types = {"Cash", "UPI", "Bank Transfer"};
  static late String _chosenType = getDefaultPaymentType();

  static List<String> getPaymentTypesList() => _types.toList();

  static void choosePaymentType(String type) {
    _chosenType = type;
  }

  static void setDefaultPaymentType() {
    _chosenType = getDefaultPaymentType();
  }

  static String getDefaultPaymentType() => "UPI";

  static String getChosenPaymentType() => _chosenType;

  static List<String> getPaymentTypesAsList() => _types.toList();
}
