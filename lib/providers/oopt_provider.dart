import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;

import '../models/oopt.dart';

class OoptProvider {

  static const listPath = 'assets/data/oopt.json';
  static const ooptPath = 'assets/data/oopt_';
  static const areaPath = '/area_1.kml';
  static const htmlPath = '/info.html';

  static Future<List<Oopt>> loadList() async {
    final data = await rootBundle.loadString(listPath);
    final body = json.decode(data);
    
    List<Oopt> result = [];
    for (final oopt in body) {
      final points = await loadArea(oopt['id']);
      result.add(Oopt.fromJson(oopt, points));
    }
    return result;
  }

  static String htmlLink(int id) {;
    return ooptPath + id.toString() + htmlPath;
  }

  static String imageLink(int id, int number) {;
    return ooptPath + id.toString() + htmlPath;
  }

  static Future<List<Point>> loadArea(int id) async {
    final data = await rootBundle.loadString(ooptPath + id.toString() + areaPath);
    try {
      final document = xml.parse(data);
      final coordinates = document.findAllElements('coordinates').single.text.trim().split(' ');
      List<Point> result = [];
      for (final coord in coordinates) {
        try {
          final point = coord.split(',');
          result.add(Point(double.parse(point[0]), double.parse(point[1])));
        } catch(ex){
        }
      }
      return result;
    } catch (ex) {
      return [];
    }
  }

}