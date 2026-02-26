import 'dart:convert';

LocationModel locationModelFromJson(String str) => LocationModel.fromJson(json.decode(str));

String locationModelToJson(LocationModel data) => json.encode(data.toJson());

class LocationModel {
  late List<String> locations;

  LocationModel({
    required this.locations,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    locations: List<String>.from(json["locations"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "locations": List<dynamic>.from(locations.map((x) => x)),
  };
}