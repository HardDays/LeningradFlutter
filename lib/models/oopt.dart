import 'dart:math';

import 'oopt_image.dart';

class OoptCategory {
  static const String naturalPark = 'prirodniy_park';
  static const String naturalMonument = 'pamyatnik_prirodi';
  static const String wildlifeSanctuary = 'zakaznik';
}

class Oopt {

  final int id;

  final String name;
  final String category;
  final String html;

  final DateTime date;

  final double lat;
  final double lng;
  final double square;

  final List<Point> points;
  final List<OoptImage> images;

  Oopt({this.id, this.name, this.html, this.category, this.date, this.lat, this.lng, this.square, this.images = const [], this.points = const []});

  factory Oopt.fromJson(Map<String, dynamic> json, String html, List<OoptImage> images, List<Point> points) {
    return Oopt(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      lat: json['lat'],
      lng: json['lng'],
      square: json['square'],
      html: html,
      points: points,
      images: images
    );
  }


}