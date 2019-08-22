import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/route.dart';
import '../models/place.dart';
import '../models/route_image.dart';

class GraphhopperProvider {

  static const url = 'http://35.204.247.246:3000';
  static const route = '/route';

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
          //'Authorization': '540f1d73-ee32-42e6-abe1-ea959d5def75'
        }
    );
  }

  static Future<String> getRoute(List<Place> places) async {
    try {
      final params = places.map((p) => 'point=${p.lat},${p.lng}').join('&');
      final data = await baseGetRequest(route + '?' + params + '&optimize=true');
      final body = json.decode(data.body);
      return body['paths'].first['points'];
    } catch (ex) {
    }
  }

}