class DocumentResponse {
  final List<DocumentData> data;

  DocumentResponse({required this.data});

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      data: (json['data'] as List)
          .map((item) => DocumentData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((item) => item.toJson()).toList()};
  }
}

class DocumentMetadata {
  final String? id;
  final String? uri;
  final String? type;

  DocumentMetadata({this.id, this.uri, this.type});

  factory DocumentMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DocumentMetadata();
    return DocumentMetadata(
      id: json['id'] as String?,
      uri: json['uri'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (uri != null) 'uri': uri,
      if (type != null) 'type': type,
    };
  }
}

class DocumentData {
  final DocumentMetadata? metadata;
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

  // SAP OData fields
  final String? locCd;
  final String? deptCd;
  final String? matnr;
  final String? jkMatnr;
  final String? maktx;
  final String? jkMaktx;
  final String? pType;
  final String? pAction;
  final String? name;
  final String? source;
  final String? reasCd;
  final String? compCd;
  final String? erdat;
  final String? ername;
  final String? fromDept;
  final String? toDept;
  final String? barcode;
  final String? manfPlant;
  final String? prodDt;
  final String? stencilno;
  final String? grade;
  final String? oth1;
  final String? oth2;
  final String? oth3;
  final String? oth4;
  final String? oth5;
  final String? postFlg;
  final String? postMsg;
  final String? qty1;
  final String? skuCnt;
  final String? issQty;
  final String? recQty;
  final String? stkQty;
  final String? dt1;
  final String? dt2;
  final String? pComp;
  final String? pFlg;

  DocumentData({
    this.metadata,
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
    this.locCd,
    this.deptCd,
    this.matnr,
    this.jkMatnr,
    this.maktx,
    this.jkMaktx,
    this.pType,
    this.pAction,
    this.name,
    this.source,
    this.reasCd,
    this.compCd,
    this.erdat,
    this.ername,
    this.fromDept,
    this.toDept,
    this.barcode,
    this.manfPlant,
    this.prodDt,
    this.stencilno,
    this.grade,
    this.oth1,
    this.oth2,
    this.oth3,
    this.oth4,
    this.oth5,
    this.postFlg,
    this.postMsg,
    this.qty1,
    this.skuCnt,
    this.issQty,
    this.recQty,
    this.stkQty,
    this.dt1,
    this.dt2,
    this.pComp,
    this.pFlg,
  });

  factory DocumentData.fromJson(Map<String, dynamic> json) {
    final metadataJson = json['__metadata'];
    final metadata = metadataJson != null
        ? DocumentMetadata.fromJson(metadataJson as Map<String, dynamic>)
        : null;

    // Support both SAP OData format and legacy MongoDB format
    final docNo = json['DocNo'] ?? json['documentNumber'];
    final docDate = json['DocDate'] ?? json['documentDate'];
    final docType = json['DocType'] ?? json['documentType'];
    final compCd = json['CompCd'] ?? json['competitorCode'];
    final reasCd = json['ReasCd'] ?? json['reasonCode'];
    final jkFlag = json['JkFlag'] ?? json['jkFlag'];
    final locCd = json['LocCd'] ?? json['location'];
    final deptCd = json['DeptCd'] ?? json['departmentCode'];
    final remarkVal = json['Remark'] ?? json['remark'];
    final pType = json['PType'] ?? json['purposeCode'];

    return DocumentData(
      metadata: metadata,
      id: _extractId(metadata) ?? json['_id'] as String?,
      documentType: _str(docType),
      documentNumber: _str(docNo) ?? '',
      documentDate: _str(docDate) ?? '',
      jkFlag: _str(jkFlag),
      competitorCode: _str(compCd),
      purposeCode: _str(pType),
      reasonCode: _str(reasCd),
      departmentCode: _str(deptCd),
      remark: _str(remarkVal),
      location: _str(locCd),
      storageLocation: _str(json['storageLocation']),
      binCode: _str(json['binCode']),
      rackCode: _str(json['rackCode']),
      locCd: _str(json['LocCd']),
      deptCd: _str(json['DeptCd']),
      matnr: _str(json['Matnr']),
      jkMatnr: _str(json['JkMatnr']),
      maktx: _str(json['Maktx']),
      jkMaktx: _str(json['JkMaktx']),
      pType: _str(json['PType']),
      pAction: _str(json['PAction']),
      name: _str(json['Name']),
      source: _str(json['Source']),
      reasCd: _str(json['ReasCd']),
      compCd: _str(json['CompCd']),
      erdat: _str(json['Erdat']),
      ername: _str(json['Ername']),
      fromDept: _str(json['FromDept']),
      toDept: _str(json['ToDept']),
      barcode: _str(json['Barcode']),
      manfPlant: _str(json['ManfPlant']),
      prodDt: _str(json['ProdDt']),
      stencilno: _str(json['Stencilno']),
      grade: _str(json['Grade']),
      oth1: _str(json['Oth1']),
      oth2: _str(json['Oth2']),
      oth3: _str(json['Oth3']),
      oth4: _str(json['Oth4']),
      oth5: _str(json['Oth5']),
      postFlg: _str(json['PostFlg']),
      postMsg: _str(json['PostMsg']),
      qty1: _str(json['Qty1']),
      skuCnt: _str(json['SkuCnt']),
      issQty: _str(json['IssQty']),
      recQty: _str(json['RecQty']),
      stkQty: _str(json['StkQty']),
      dt1: _str(json['Dt1']),
      dt2: _str(json['Dt2']),
      pComp: _str(json['PComp']),
      pFlg: _str(json['PFlg']),
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static String? _extractId(DocumentMetadata? m) {
    if (m?.id == null) return null;
    final uri = m!.id!;
    final match = RegExp(r"'\s*([^']+)\s*'").firstMatch(uri);
    return match?.group(1);
  }

  Map<String, dynamic> toJson() {
    return {
      if (metadata != null) '__metadata': metadata!.toJson(),
      if (id != null) '_id': id,
      if (documentType != null) 'DocType': documentType,
      'DocNo': documentNumber,
      'DocDate': documentDate,
      if (jkFlag != null) 'JkFlag': jkFlag,
      if (competitorCode != null) 'CompCd': competitorCode,
      if (purposeCode != null) 'PType': purposeCode,
      if (reasonCode != null) 'ReasCd': reasonCode,
      if (storageLocation != null) 'storageLocation': storageLocation,
      if (binCode != null) 'binCode': binCode,
      if (rackCode != null) 'rackCode': rackCode,
      if (departmentCode != null) 'DeptCd': departmentCode,
      if (remark != null) 'Remark': remark,
      if (location != null) 'LocCd': location,
    };
  }
}
