import 'dart:convert';
import 'package:http/http.dart' as http;

class ReceivingDetailModel {
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

  ReceivingDetailModel({
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

  factory ReceivingDetailModel.fromJson(Map<String, dynamic> json) {
    return ReceivingDetailModel(
      locCd: json['LocCd'] ?? '',
      deptCd: json['DeptCd'] ?? '',
      matnr: json['Matnr'] ?? '',
      jkMatnr: json['JkMatnr'] ?? '',
      maktx: json['Maktx'] ?? '',
      jkMaktx: json['JkMaktx'] ?? '',
      pType: json['PType'] ?? '',
      pAction: json['PAction'] ?? '',
      name: json['Name'] ?? '',
      remark: json['Remark'] ?? '',
      docNo: json['DocNo'] ?? '',
      docDate: json['DocDate'] ?? '',
      docType: json['DocType'] ?? '',
      source: json['Source'] ?? '',
      reasCd: json['ReasCd'] ?? '',
      jkFlag: json['JkFlag'] ?? '',
      compCd: json['CompCd'] ?? '',
      erdat: json['Erdat'] ?? '',
      ername: json['Ername'] ?? '',
      fromDept: json['FromDept'] ?? '',
      toDept: json['ToDept'] ?? '',
      barcode: json['Barcode'] ?? '',
      manfPlant: json['ManfPlant'] ?? '',
      prodDt: json['ProdDt'] ?? '',
      stencilno: json['Stencilno'] ?? '',
      grade: json['Grade'] ?? '',
      oth1: json['Oth1'] ?? '',
      oth2: json['Oth2'] ?? '',
      oth3: json['Oth3'] ?? '',
      oth4: json['Oth4'] ?? '',
      oth5: json['Oth5'] ?? '',
      postFlg: json['PostFlg'] ?? '',
      postMsg: json['PostMsg'] ?? '',
      qty1: json['Qty1'] ?? '',
      skuCnt: json['SkuCnt'] ?? '',
      issQty: json['IssQty'] ?? '',
      recQty: json['RecQty'] ?? '',
      stkQty: json['StkQty'] ?? '',
      dt1: json['Dt1'] ?? '',
      dt2: json['Dt2'] ?? '',
      pComp: json['PComp'] ?? '',
      pFlg: json['PFlg'] ?? '',
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

  static List<ReceivingDetailModel> listFromJson(List<dynamic> list) {
    return list.map((item) => ReceivingDetailModel.fromJson(item)).toList();
  }
}

/// Fetch receiving details from API and parse into [ReceivingDetailListResponse].
///
/// [docNo] and [location] are used to build the request URL.
/// [token] is the raw JWT (without the `Bearer ` prefix).
Future<ReceivingDetailListResponse> fetchReceivingDetails({
  required String docNo,
  required String location,
  required String token,
}) async {
  final headers = {
    'Authorization': 'Bearer $token',
  };

  final uri = Uri.parse(
    'http://10.10.10.129:7000/api/v1/pdc/documents/$docNo?location=$location',
  );

  final request = http.Request('GET', uri);
  request.headers.addAll(headers);

  final http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final String body = await response.stream.bytesToString();
    final Map<String, dynamic> jsonBody =
        json.decode(body) as Map<String, dynamic>;
    return ReceivingDetailListResponse.fromJson(jsonBody);
  } else {
    throw Exception(
      'Failed to load receiving details: ${response.statusCode} ${response.reasonPhrase}',
    );
  }
}

// To parse the whole sample (with the 'data' array at top level):
class ReceivingDetailListResponse {
  final List<ReceivingDetailModel> data;

  ReceivingDetailListResponse({required this.data});

  factory ReceivingDetailListResponse.fromJson(Map<String, dynamic> json) {
    return ReceivingDetailListResponse(
      data: json['data'] != null
          ? ReceivingDetailModel.listFromJson(json['data'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}