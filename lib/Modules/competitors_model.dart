class CompetitorResponse {
  final List<Competitor> data;

  CompetitorResponse({required this.data});

  factory CompetitorResponse.fromJson(Map<String, dynamic> json) {
    return CompetitorResponse(
      data: (json['data'] as List)
          .map((item) => Competitor.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Competitor {
  final String competitorCode;
  final String competitorName;

  Competitor({
    required this.competitorCode,
    required this.competitorName,
  });

  factory Competitor.fromJson(Map<String, dynamic> json) {
    return Competitor(
      competitorCode: json['competitorCode'] as String,
      competitorName: json['competitorName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competitorCode': competitorCode,
      'competitorName': competitorName,
    };
  }
}