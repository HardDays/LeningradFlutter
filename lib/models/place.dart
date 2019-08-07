import 'route_image.dart';

class PlaceType {
  static const all = [
    'any',
    'view',
    'view_place',
    'water',
    'bridge',
    'way',
    'bin',
    'sight',
    'fire',
    'eco',
    'talking',
    'birds',
    'camping',
  ];
}

class Place {
  final int id;
  final String name;
  final String description;
  final String type;
  final double lat;
  final double lng;

  Place(
    {
      this.id,
      this.name,
      this.description,
      this.lat,
      this.type,
      this.lng
    }
  );

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      description: json['description'],
      lat: json['lat'] ?? 0,
      lng: json['lng'] ?? 0,
      type: json['type'] ?? 'any'
    );
  }
}