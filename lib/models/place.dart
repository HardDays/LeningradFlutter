import 'route_image.dart';

class Place {
  final int id;
  final String name;
  final String description;
  final double lat;
  final double lng;

  Place(
    {
      this.id,
      this.name,
      this.description,
      this.lat,
      this.lng
    }
  );

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      description: json['description'],
      lat: json['lat'] ?? 0,
      lng: json['lng'] ?? 0
    );
  }
}