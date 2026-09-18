class CompetitorBarcodeResponse {
  final List<CompetitorBarcode> data;

  CompetitorBarcodeResponse({required this.data});

  factory CompetitorBarcodeResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return CompetitorBarcodeResponse(
      data: raw is List
          ? raw
                .map(
                  (item) => CompetitorBarcode.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
    );
  }
}

class CompetitorBarcode {
  final String barcode;
  final String category;
  final String size;
  final String make;
  final String brand;
  final String pattern;
  final String serialNo;
  final String remark;
  final String productionDate;
  final String erdat;
  final String jkMatnr;

  CompetitorBarcode({
    required this.barcode,
    required this.category,
    required this.size,
    required this.make,
    required this.brand,
    required this.pattern,
    required this.serialNo,
    required this.remark,
    required this.productionDate,
    required this.erdat,
    required this.jkMatnr,
  });

  factory CompetitorBarcode.fromJson(Map<String, dynamic> json) {
    String read(String key) => json[key]?.toString() ?? "";

    return CompetitorBarcode(
      barcode: read('Barcode'),
      category: read('Catg'),
      size: read('Ysize'),
      make: read('Make'),
      brand: read('Brand'),
      pattern: read('Pattern'),
      serialNo: read('SerialNo'),
      remark: read('Remark'),
      productionDate: read('ProdDt'),
      erdat: read('Erdat'),
      jkMatnr: read('JkMatnr'),
    );
  }
}
