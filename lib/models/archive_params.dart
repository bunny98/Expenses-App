import 'dart:convert';

class ArchiveParams {
  static const sharedPrefKey = "archiveParams";
  final DateTime nextArchiveOn;
  final int archiveOnEvery;

  ArchiveParams({required this.nextArchiveOn, required this.archiveOnEvery});

  factory ArchiveParams.fromArchiveOnEvery({required int archiveOnEvery}) {
    var today = DateTime.now();
    return ArchiveParams(
        nextArchiveOn: DateTime(
            today.year,
            today.day >= archiveOnEvery ? today.month + 1 : today.month,
            archiveOnEvery),
        archiveOnEvery: archiveOnEvery);
  }

  factory ArchiveParams.fromJson(Map<String, dynamic> jsonData) {
    return ArchiveParams(
        nextArchiveOn:
            DateTime.fromMillisecondsSinceEpoch(jsonData['nextArchiveOn']),
        archiveOnEvery: jsonData['archiveOnEvery']);
  }

  Map<String, dynamic> toMap() => {
        'nextArchiveOn': nextArchiveOn.millisecondsSinceEpoch,
        'archiveOnEvery': archiveOnEvery,
      };

  static String encode(ArchiveParams archiveParams) =>
      json.encode(archiveParams.toMap());
  static ArchiveParams decode(String expense) =>
      ArchiveParams.fromJson(json.decode(expense));
}
