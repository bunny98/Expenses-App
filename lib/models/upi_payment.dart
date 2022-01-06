class UPIPayment {
  late double _amount;
  late String _recipientName;
  late String _upiID;

  UPIPayment({double? amount, String? recipientName, String? upiId}) {
    _amount = amount ?? 0;
    _recipientName = recipientName ?? "";
    _upiID = upiId ?? "";
  }

  double get amount => _amount;

  set amount(double amount) {
    _amount = amount;
  }

  String get upiID => _upiID;

  set upiID(String upiID) {
    _upiID = upiID;
  }

  String get recipientName => _recipientName;

  set recipientName(String recipientName) {
    _recipientName = recipientName;
  }

  @override
  String toString() => "$_amount $_recipientName $_upiID";
}
