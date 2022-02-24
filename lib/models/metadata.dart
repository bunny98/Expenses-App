// METADATA ID WILL BE STORED IN SQL as METADATATYPE_TIME_TYPESPECIFICID
class Metadata {
  static const String idSeparator = "_";
  final String data;
  final String metadataType;
  final String typeSpecificId;
  final int time;

  Metadata(
      {required this.data,
      required this.metadataType,
      required this.typeSpecificId,
      required this.time});

  factory Metadata.fromJson(Map<String, dynamic> jsonData) {
    List<String> idParts = (jsonData['id'] as String).split(idSeparator);
    String metadataType = idParts[0];
    int time = int.parse(idParts[1]);
    String typeSpecificId = idParts[2];
    return Metadata(
        data: jsonData["data"],
        metadataType: metadataType,
        time: time,
        typeSpecificId: typeSpecificId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': "$metadataType$idSeparator$time$idSeparator$typeSpecificId",
      'data': data
    };
  }

  @override
  String toString() {
    return 'Metadata{id: $metadataType$idSeparator$time$idSeparator$typeSpecificId, data: $data}';
  }

  static String getSQLCreateDatatypes() =>
      "(id TEXT PRIMARY KEY, data TEXT NOT NULL)";

  static String getTypeSearchCondition(String type) => "id LIKE '$type%'";

  static String getTypeAndTypeIdSearchCondition(
          {required String type, required String typeId}) =>
      "id LIKE '$type$idSeparator%$idSeparator$typeId'";
}
