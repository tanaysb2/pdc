import 'dart:convert';

MaterialPlantModel materialPlantModelFromJson(String str) =>
    MaterialPlantModel.fromJson(json.decode(str));

String materialPlantModelToJson(MaterialPlantModel data) =>
    json.encode(data.toJson());

class MaterialPlantModel {
  final List<Plant> plants;

  MaterialPlantModel({
    required this.plants,
  });

  factory MaterialPlantModel.fromJson(Map<String, dynamic> json) =>
      MaterialPlantModel(
        plants: List<Plant>.from(json["plants"].map((x) => Plant.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plants": List<dynamic>.from(plants.map((x) => x.toJson())),
      };
}

class Plant {
  final String id;
  final String description;
  final String code;
  final String identifiers;

  Plant({
    required this.id,
    required this.description,
    required this.code,
    required this.identifiers,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
        id: json["_id"],
        description: json["description"],
        code: json["code"],
        identifiers: json["identifier"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "description": description,
        "code": code,
        "identifier": identifiers,
      };
}
