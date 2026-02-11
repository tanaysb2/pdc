class DocumentResponse {
  final List<DocumentData> data;

  DocumentResponse({required this.data});

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      data: (json['data'] as List)
          .map((item) => DocumentData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class DocumentData {
  final String? id;
  final String? documentType;
  final String documentNumber;
  final String documentDate;
  final String? jkFlag;
  final String? competitorCode;
  final String? purposeCode;
  final String? reasonCode;
  final String? storageLocation;
  final String? binCode;
  final String? rackCode;
  final String? departmentCode;
  final String? remark;
  final String? location;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  /// Backward compatibility: maps to competitorCode.
   

  DocumentData({
    this.id,
    this.documentType,
    required this.documentNumber,
    required this.documentDate,
    this.jkFlag,
    this.competitorCode,
    this.purposeCode,
    this.reasonCode,
    this.storageLocation,
    this.binCode,
    this.rackCode,
    this.departmentCode,
    this.remark,
    this.location,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory DocumentData.fromJson(Map<String, dynamic> json) {
    return DocumentData(
      id: json['_id'] as String?,
      documentType: json['documentType'] as String?,
      documentNumber: json['documentNumber'] as String,
      documentDate: json['documentDate'] as String,
      jkFlag: json['jkFlag'] as String?,
      competitorCode: json['competitorCode'] as String?,
      purposeCode: json['purposeCode'] as String?,
      reasonCode: json['reasonCode'] as String?,
      storageLocation: json['storageLocation'] as String?,
      binCode: json['binCode'] as String?,
      rackCode: json['rackCode'] as String?,
      departmentCode: json['departmentCode'] as String?,
      remark: json['remark'] as String?,
      location: json['location'] as String?,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (documentType != null) 'documentType': documentType,
      'documentNumber': documentNumber,
      'documentDate': documentDate,
      if (jkFlag != null) 'jkFlag': jkFlag,
      if (competitorCode != null) 'competitorCode': competitorCode,
      if (purposeCode != null) 'purposeCode': purposeCode,
      if (reasonCode != null) 'reasonCode': reasonCode,
      if (storageLocation != null) 'storageLocation': storageLocation,
      if (binCode != null) 'binCode': binCode,
      if (rackCode != null) 'rackCode': rackCode,
      if (departmentCode != null) 'departmentCode': departmentCode,
      if (remark != null) 'remark': remark,
      if (location != null) 'location': location,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (v != null) '__v': v,
    };
  }
}