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
  final String description;
  final String annotation;
  final String features;
  final String law;

  final DateTime date;

  final double lat;
  final double lng;
  final double square;

  final List<List<Point>> points;
  final List<OoptImage> images;
  final List<String> rules;
  final List<String> ruleImages;
  final List<String> objectives;
  final List<String> norm;
  final List<String> normLinks;

  Oopt(
    {
      this.id, 
      this.name, 
      this.html, 
      this.category, 
      this.date, 
      this.lat, 
      this.lng, 
      this.square, 
      this.description,
      this.law,
      this.annotation,
      this.features,
      this.images = const [], 
      this.points = const [],
      this.rules = const [],
      this.ruleImages = const [],
      this.objectives = const [],
      this.norm = const [],
      this.normLinks = const []
    }
  );

  factory Oopt.fromJson(Map<String, dynamic> json, String html, List<OoptImage> images, List<List<Point>> points) {
    return Oopt(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      lat: json['lat'],
      lng: json['lng'],
      square: json['square']?.toDouble() ?? 0.0,
      description: json['description'],
      law: json['law'],
      annotation: json['annotation'],
      features: json['features'],
      objectives: List<String>.from(json['objectives']),
      ruleImages: List<String>.from(json['rule_images']),
      rules: List<String>.from(json['rules']),
      norm: List<String>.from(json['norm']),
      normLinks: List<String>.from(json['norm_links']),
      html: html,
      points: points,
      images: images
    );
  }


}