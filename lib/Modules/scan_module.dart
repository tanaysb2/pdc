class ScanModuleResponse {
  final ScanModuleData data;
  final String message;

  ScanModuleResponse({required this.data, required this.message});

  factory ScanModuleResponse.fromJson(Map<String, dynamic> json) {
    return ScanModuleResponse(
      data: ScanModuleData.fromJson(json['data']),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'message': message,
    };
  }
}

class ScanModuleData {
  final String id;
  final String documentType;
  final String documentNumber;
  final String documentDate;
  final String jkFlag;
  final String? competitorCode;
  final String purposeCode;
  final String reasonCode;
  final String storageLocation;
  final String binCode;
  final String rackCode;
  final String departmentCode;
  final String remark;
  final int scannedQuantity;
  final String markedComplete;
  final String location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String barcode;

  ScanModuleData({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.documentDate,
    required this.jkFlag,
    this.competitorCode,
    required this.purposeCode,
    required this.reasonCode,
    required this.storageLocation,
    required this.binCode,
    required this.rackCode,
    required this.departmentCode,
    required this.remark,
    required this.scannedQuantity,
    required this.markedComplete,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.barcode,
  });

  factory ScanModuleData.fromJson(Map<String, dynamic> json) {
    return ScanModuleData(
      id: json['_id'] as String,
      documentType: json['documentType'] as String,
      documentNumber: json['documentNumber'] as String,
      documentDate: json['documentDate'] as String,
      jkFlag: json['jkFlag'] as String,
      competitorCode: json['competitorCode'],
      purposeCode: json['purposeCode'] as String,
      reasonCode: json['reasonCode'] as String,
      storageLocation: json['storageLocation'] as String,
      binCode: json['binCode'] as String,
      rackCode: json['rackCode'] as String,
      departmentCode: json['departmentCode'] as String,
      remark: json['remark'] as String,
      scannedQuantity: json['scannedQuantity'] is int
          ? json['scannedQuantity']
          : int.tryParse(json['scannedQuantity']?.toString() ?? '0') ?? 0,
      markedComplete: json['markedComplete'] as String,
      location: json['location'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: json['__v'] is int
          ? json['__v']
          : int.tryParse(json['__v']?.toString() ?? '0') ?? 0,
      barcode: json['barcode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'documentDate': documentDate,
      'jkFlag': jkFlag,
      'competitorCode': competitorCode,
      'purposeCode': purposeCode,
      'reasonCode': reasonCode,
      'storageLocation': storageLocation,
      'binCode': binCode,
      'rackCode': rackCode,
      'departmentCode': departmentCode,
      'remark': remark,
      'scannedQuantity': scannedQuantity,
      'markedComplete': markedComplete,
      'location': location,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'barcode': barcode,
    };
  }
}