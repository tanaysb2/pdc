class ModuleResponse {
  final List<Module> data;

  ModuleResponse({required this.data});

  factory ModuleResponse.fromJson(Map<String, dynamic> json) {
    return ModuleResponse(
      data: (json['data'] as List)
          .map((item) => Module.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Module {
  final String moduleCode;
  final String moduleName;

  Module({
    required this.moduleCode,
    required this.moduleName,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      moduleCode: json['moduleCode'] as String,
      moduleName: json['moduleName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleCode': moduleCode,
      'moduleName': moduleName,
    };
  }
}