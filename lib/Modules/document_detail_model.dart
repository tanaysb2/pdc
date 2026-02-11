class DocumentDetailResponse {
  final DocumentDetailData data;

  DocumentDetailResponse({required this.data});

  factory DocumentDetailResponse.fromJson(Map<String, dynamic> json) {
    return DocumentDetailResponse(
      data: DocumentDetailData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class DocumentDetailData {
  final String id;
  final String documentType;
  final String documentNumber;
  final DateTime documentDate;
  final String jkFlag;
  final String competitorCode;
  final String purposeCode;
  final String reasonCode;
  final String storageLocation;
  final String binCode;
  final String rackCode;
  final String departmentCode;
  final String remark;
  final String location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  DocumentDetailData({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.documentDate,
    required this.jkFlag,
    required this.competitorCode,
    required this.purposeCode,
    required this.reasonCode,
    required this.storageLocation,
    required this.binCode,
    required this.rackCode,
    required this.departmentCode,
    required this.remark,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory DocumentDetailData.fromJson(Map<String, dynamic> json) {
    return DocumentDetailData(
      id: json['_id'] as String,
      documentType: json['documentType'] as String,
      documentNumber: json['documentNumber'] as String,
      documentDate: DateTime.parse(json['documentDate'] as String),
      jkFlag: json['jkFlag'] as String,
      competitorCode: json['competitorCode'] as String,
      purposeCode: json['purposeCode'] as String,
      reasonCode: json['reasonCode'] as String,
      storageLocation: json['storageLocation'] as String,
      binCode: json['binCode'] as String,
      rackCode: json['rackCode'] as String,
      departmentCode: json['departmentCode'] as String,
      remark: json['remark'] as String,
      location: json['location'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'documentDate': documentDate.toIso8601String(),
      'jkFlag': jkFlag,
      'competitorCode': competitorCode,
      'purposeCode': purposeCode,
      'reasonCode': reasonCode,
      'storageLocation': storageLocation,
      'binCode': binCode,
      'rackCode': rackCode,
      'departmentCode': departmentCode,
      'remark': remark,
      'location': location,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}