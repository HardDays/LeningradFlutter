import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/oopt.dart';
import '../models/oopt_image.dart';

class OoptProvider {

  static const listPath = 'assets/data/oopt.json';
  static const imagesPath = 'assets/data/oopt_images.json';
  static const ooptPath = 'assets/data/oopt_';
  static const areaPath = '/area_1.kml';
  static const htmlPath = '/info.html';

  static Future<List<Oopt>> loadList() async {
    final data = await rootBundle.loadString(listPath);
    final body = json.decode(data);
    
    final images = await loadImages();

    List<Oopt> result = [];
    for (final oopt in body) {
      final points = await loadArea(oopt['id']);
      result.add(Oopt.fromJson(oopt, ooptPath + oopt['id'].toString() + htmlPath, images[oopt['id'] - 1], points));
    }
    return result;
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

  static Future<List<List<OoptImage>>> loadImages() async {
    final data = await rootBundle.loadString(imagesPath);
    final body = json.decode(data);

    List<List<OoptImage>> result = [];
    for (final imgs in body) {
      final List<OoptImage> res = [];
      for (final img in imgs) {
        final link = ooptPath + img['oopt_id'].toString() + '/pic_${img['id']}.jpg';
        res.add(OoptImage(author: img['author'], link: link));
      }
      result.add(res);
    }
    return result;
  }

  static Future<List<Uint8List>> compressImages(List<Oopt> oopt) async {
    final List<Uint8List> result = [];
    for (final oopt in oopt) {
      final list = await FlutterImageCompress.compressAssetImage(oopt.images.first.link,
        minHeight: 300,
        minWidth: 300,
        quality: 90
      );
      result.add(Uint8List.fromList(list));
    }
    return result;
  }


  static String imageLink(int id, int number) {;
    return ooptPath + id.toString() + htmlPath;
  }

}