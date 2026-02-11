class PurposeResponse {
  final List<Purpose> data;

  PurposeResponse({required this.data});

  factory PurposeResponse.fromJson(Map<String, dynamic> json) {
    return PurposeResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Purpose.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((item) => item.toJson()).toList()};
  }
}

class Purpose {
  final String purposeCode;
  final String purposeName;

  Purpose({required this.purposeCode, required this.purposeName});

  factory Purpose.fromJson(Map<String, dynamic> json) {
    return Purpose(
      purposeCode: json['purposeCode'] ?? "",
      purposeName: json['purposeName'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"purposeCode": purposeCode, "purposeName": purposeName};
  }
}

List<Purpose> parsePurposesFromJson(Map<String, dynamic> json) {
  final data = json['data'] as List<dynamic>? ?? [];
  return data.map((e) => Purpose.fromJson(e)).toList();
}
