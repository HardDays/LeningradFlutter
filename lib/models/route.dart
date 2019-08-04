import 'route_image.dart';

class Route {
  final int id;
  final String name;
  final String description;
  final RouteImage image;

  Route(
    {
      this.id,
      this.name,
      this.description,
      this.image
    }
  );

  factory Route.fromJson(Map<String, dynamic> json, {RouteImage image}) {
    return Route(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: image
    );
  }
}