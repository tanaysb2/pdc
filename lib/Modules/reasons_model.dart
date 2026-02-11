class ReasonResponse {
  final List<Reason> data;

  ReasonResponse({required this.data});

  factory ReasonResponse.fromJson(Map<String, dynamic> json) {
    return ReasonResponse(
      data: (json['data'] as List)
          .map((item) => Reason.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((item) => item.toJson()).toList()};
  }
}

class Reason {
  final String reasonCode;
  final String reasonName;

  Reason({required this.reasonCode, required this.reasonName});

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      reasonCode: json['reasonCode'] as String,
      reasonName: json['reasonName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'reasonCode': reasonCode, 'reasonName': reasonName};
  }
}
