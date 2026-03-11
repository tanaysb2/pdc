class DocumentDetailResponse {
  final List<DocumentDetailData> data;

  DocumentDetailResponse({required this.data});

  factory DocumentDetailResponse.fromJson(Map<String, dynamic> json) {
    return DocumentDetailResponse(
      data: (json['data'] as List<dynamic>).map((e) => DocumentDetailData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class DocumentDetailData {
  final String locCd;
  final String deptCd;
  final String matnr;
  final String jkMatnr;
  final String maktx;
  final String jkMaktx;
  final String pType;
  final String pAction;
  final String name;
  final String remark;
  final String docNo;
  final String docDate;
  final String docType;
  final String source;
  final String reasCd;
  final String jkFlag;
  final String compCd;
  final String erdat;
  final String ername;
  final String fromDept;
  final String toDept;
  final String barcode;
  final String manfPlant;
  final String prodDt;
  final String stencilno;
  final String grade;
  final String oth1;
  final String oth2;
  final String oth3;
  final String oth4;
  final String oth5;
  final String postFlg;
  final String postMsg;
  final String qty1;
  final String skuCnt;
  final String issQty;
  final String recQty;
  final String stkQty;
  final String dt1;
  final String dt2;
  final String pComp;
  final String pFlg;

  DocumentDetailData({
    required this.locCd,
    required this.deptCd,
    required this.matnr,
    required this.jkMatnr,
    required this.maktx,
    required this.jkMaktx,
    required this.pType,
    required this.pAction,
    required this.name,
    required this.remark,
    required this.docNo,
    required this.docDate,
    required this.docType,
    required this.source,
    required this.reasCd,
    required this.jkFlag,
    required this.compCd,
    required this.erdat,
    required this.ername,
    required this.fromDept,
    required this.toDept,
    required this.barcode,
    required this.manfPlant,
    required this.prodDt,
    required this.stencilno,
    required this.grade,
    required this.oth1,
    required this.oth2,
    required this.oth3,
    required this.oth4,
    required this.oth5,
    required this.postFlg,
    required this.postMsg,
    required this.qty1,
    required this.skuCnt,
    required this.issQty,
    required this.recQty,
    required this.stkQty,
    required this.dt1,
    required this.dt2,
    required this.pComp,
    required this.pFlg,
  });

  factory DocumentDetailData.fromJson(Map<String, dynamic> json) {
    return DocumentDetailData(
      locCd: json['LocCd'] as String? ?? "",
      deptCd: json['DeptCd'] as String? ?? "",
      matnr: json['Matnr'] as String? ?? "",
      jkMatnr: json['JkMatnr'] as String? ?? "",
      maktx: json['Maktx'] as String? ?? "",
      jkMaktx: json['JkMaktx'] as String? ?? "",
      pType: json['PType'] as String? ?? "",
      pAction: json['PAction'] as String? ?? "",
      name: json['Name'] as String? ?? "",
      remark: json['Remark'] as String? ?? "",
      docNo: json['DocNo'] as String? ?? "",
      docDate: json['DocDate'] as String? ?? "",
      docType: json['DocType'] as String? ?? "",
      source: json['Source'] as String? ?? "",
      reasCd: json['ReasCd'] as String? ?? "",
      jkFlag: json['JkFlag'] as String? ?? "",
      compCd: json['CompCd'] as String? ?? "",
      erdat: json['Erdat'] as String? ?? "",
      ername: json['Ername'] as String? ?? "",
      fromDept: json['FromDept'] as String? ?? "",
      toDept: json['ToDept'] as String? ?? "",
      barcode: json['Barcode'] as String? ?? "",
      manfPlant: json['ManfPlant'] as String? ?? "",
      prodDt: json['ProdDt'] as String? ?? "",
      stencilno: json['Stencilno'] as String? ?? "",
      grade: json['Grade'] as String? ?? "",
      oth1: json['Oth1'] as String? ?? "",
      oth2: json['Oth2'] as String? ?? "",
      oth3: json['Oth3'] as String? ?? "",
      oth4: json['Oth4'] as String? ?? "",
      oth5: json['Oth5'] as String? ?? "",
      postFlg: json['PostFlg'] as String? ?? "",
      postMsg: json['PostMsg'] as String? ?? "",
      qty1: json['Qty1'] as String? ?? "",
      skuCnt: json['SkuCnt'] as String? ?? "",
      issQty: json['IssQty'] as String? ?? "",
      recQty: json['RecQty'] as String? ?? "",
      stkQty: json['StkQty'] as String? ?? "",
      dt1: json['Dt1'] as String? ?? "",
      dt2: json['Dt2'] as String? ?? "",
      pComp: json['PComp'] as String? ?? "",
      pFlg: json['PFlg'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LocCd': locCd,
      'DeptCd': deptCd,
      'Matnr': matnr,
      'JkMatnr': jkMatnr,
      'Maktx': maktx,
      'JkMaktx': jkMaktx,
      'PType': pType,
      'PAction': pAction,
      'Name': name,
      'Remark': remark,
      'DocNo': docNo,
      'DocDate': docDate,
      'DocType': docType,
      'Source': source,
      'ReasCd': reasCd,
      'JkFlag': jkFlag,
      'CompCd': compCd,
      'Erdat': erdat,
      'Ername': ername,
      'FromDept': fromDept,
      'ToDept': toDept,
      'Barcode': barcode,
      'ManfPlant': manfPlant,
      'ProdDt': prodDt,
      'Stencilno': stencilno,
      'Grade': grade,
      'Oth1': oth1,
      'Oth2': oth2,
      'Oth3': oth3,
      'Oth4': oth4,
      'Oth5': oth5,
      'PostFlg': postFlg,
      'PostMsg': postMsg,
      'Qty1': qty1,
      'SkuCnt': skuCnt,
      'IssQty': issQty,
      'RecQty': recQty,
      'StkQty': stkQty,
      'Dt1': dt1,
      'Dt2': dt2,
      'PComp': pComp,
      'PFlg': pFlg,
    };
  }
}