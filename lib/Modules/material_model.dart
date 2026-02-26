import 'dart:convert';

MaterialModel materialModelFromJson(String str) =>
    MaterialModel.fromJson(json.decode(str));

String materialModelToJson(MaterialModel data) => json.encode(data.toJson());

class MaterialModel {
  late List<MaterialItem> materials;

  MaterialModel({
    required this.materials,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
        materials: List<MaterialItem>.from(
            json["materials"].map((x) => MaterialItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "materials": List<dynamic>.from(materials.map((x) => x.toJson())),
      };
}

class MaterialItem {
  final String code;
  final String description;

  MaterialItem({
    required this.code,
    required this.description,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) => MaterialItem(
        code: json["code"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "description": description,
      };
}
