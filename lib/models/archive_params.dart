import 'dart:convert';

class ArchiveParams {
  static const sharedPrefKey = "archiveParams";
  final DateTime nextArchiveOn;
  final DateTime? prevArchiveOn;
  final int archiveOnEvery;

  ArchiveParams(
      {required this.nextArchiveOn,
      this.prevArchiveOn,
      required this.archiveOnEvery});

  factory ArchiveParams.fromArchiveOnEvery(
      {required int archiveOnEvery, DateTime? previouslyAchivedOn}) {
    var today = DateTime.now();
    return ArchiveParams(
        prevArchiveOn: previouslyAchivedOn,
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
        prevArchiveOn: jsonData['prevArchiveOn'] != -1
            ? DateTime.fromMillisecondsSinceEpoch(jsonData['prevArchiveOn'])
            : null,
        archiveOnEvery: jsonData['archiveOnEvery']);
  }

  Map<String, dynamic> toMap() => {
        'nextArchiveOn': nextArchiveOn.millisecondsSinceEpoch,
        'prevArchiveOn':
            prevArchiveOn != null ? prevArchiveOn!.millisecondsSinceEpoch : -1,
        'archiveOnEvery': archiveOnEvery,
      };

  static String encode(ArchiveParams archiveParams) =>
      json.encode(archiveParams.toMap());
  static ArchiveParams decode(String expense) =>
      ArchiveParams.fromJson(json.decode(expense));
}
