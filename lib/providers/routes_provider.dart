import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/route.dart';
import '../models/place.dart';
import '../models/route_image.dart';

class RoutesProvider {

  static const url = 'https://lenobl.herokuapp.com';
  static const routes = '/get_routes';
  static const routePlaces = '/get_route_places';

  static String queryParams(Map<String, dynamic> params){
    String queryParams = '';
    if (params != null && params.isNotEmpty){
      queryParams = '?';

      for (var param in params.keys){
        var val = params[param];
        if (val != null){
          if (val is List<String>){
            for (var arr in val){
              queryParams += '$param%5B%5D=$arr&';
            }
          } else {
            queryParams += '$param=$val&';
          }
        }
      }
    }
    return queryParams;
  }

  static Future<http.Response> baseGetRequest(String method, {Map<String, dynamic> params}) async {
    return await http.get(url + method + queryParams(params), 
      headers: {
        'Authorization': '540f1d73-ee32-42e6-abe1-ea959d5def75'
      }
    );
  }

  static Future<List<Route>> getRoutes() async {
    try {
      final data = await baseGetRequest(routes);
      final body = json.decode(data.body);
      List<Route> res = [];
      for (final route in body) {
        try {
          if (route['image'] != null) {
            final image = base64Decode(route['image'].replaceAll(RegExp(r"^data:image\/[a-z]+;base64,"), ''));
            final compressed = await FlutterImageCompress.compressWithList(image.toList(),
              minHeight: 800,
              minWidth: 600,
              quality: 90
            );
            res.add(Route.fromJson(route, image: RouteImage(image, Uint8List.fromList(compressed))));
          } else {
            res.add(Route.fromJson(route));
          }
        } catch (ex) {
          
        }
      }
      return res;
    } catch (ex) {
      print(ex);
      return [];
    }
  }

   static Future<List<Place>> getRoutePlaces(int id) async {
    try {
      final data = await baseGetRequest(routePlaces + '/$id');
      final body = json.decode(data.body);
      List<Place> res = [];
      for (final place in body) {
        try {
          res.add(Place.fromJson(place));
        } catch (ex) {
        }
      }
      return res;
    } catch (ex) {
      print(ex);
      return [];
    }
  }

  static Future<List<List<Point>>> getRoutePoints(int id) async {
    try {
      final data = await rootBundle.loadString('assets/data/routes/$id.gpx');
      final document = xml.parse(data);
      List<List<Point>> result = [];
      for (final track in document.findAllElements('trk')) {
        List<Point> current = [];
        for (final point in track.findAllElements('trkpt')) {
          final lat = double.parse(point.getAttribute('lat'));
          final lon = double.parse(point.getAttribute('lon'));
          current.add(Point(lat, lon));
        }
        result.add(current);
      }
      return result;
    } catch (ex) {
    }
  }

}