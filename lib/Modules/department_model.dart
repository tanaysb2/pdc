class DepartmentResponse {
  final List<Department> data;

  DepartmentResponse({required this.data});

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentResponse(
      data: (json['data'] as List)
          .map((item) => Department.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((item) => item.toJson()).toList()};
  }
}

class Department {
  final String departmentCode;
  final String departmentName;

  Department({required this.departmentCode, required this.departmentName});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departmentCode: json['departmentCode'] as String,
      departmentName: json['departmentName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'departmentCode': departmentCode, 'departmentName': departmentName};
  }
}
