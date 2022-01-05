class UPIPayment {
  late int _amount;
  late String _recipientName;
  late String _upiID;
  late bool _isFinal;

  UPIPayment({int? amount, String? recipientName, String? upiId}) {
    _amount = amount ?? 0;
    _recipientName = recipientName ?? "";
    _upiID = upiId ?? "";
    _isFinal = false;
  }

  int get amount => _amount;

  set amount(int amount) {
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

  bool get isFinal => _isFinal;

  set isFinal(bool isFinal) {
    _isFinal = isFinal;
  }

  @override
  String toString() => "$_amount $_recipientName $_upiID";
}
