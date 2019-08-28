import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../resources/markers.dart';

import '../../../models/place.dart';
import '../../../models/route.dart' as r;

import '../../../storage/repository.dart';

class RoutePageBloc {

  final repository = Repository();

  BehaviorSubject<bool> satelite;
  BehaviorSubject<List<Place>> places;
  BehaviorSubject<List<List<r.Point>>> polyline;

  RoutePageBloc() {
    satelite = BehaviorSubject<bool>.seeded(false);
    places = BehaviorSubject<List<Place>>();
    polyline = BehaviorSubject<List<List<r.Point>>>();
  }

  void load(r.Route route) async {
    final placeRes = await repository.getRoutePlaces(route.id);
    try {
      final points = await repository.getRoutePoints(route.id);
      if (points != null) {
        polyline.sink.add(points);
      } else {
        final polyRes = await repository.getRoutePolyline(route.id, placeRes);
        final decoded = PolylinePoints().decodePolyline(polyRes).map((p) => r.Point(p.latitude, p.longitude, null)).toList();
        polyline.sink.add([decoded]);
      }

    } catch (ex) {
      polyline.sink.add([placeRes.map((p) => r.Point(p.lat, p.lng, null)).toList()]);
    }
    places.sink.add(placeRes);
  } 

  
  void changeMapType() {
    satelite.sink.add(!satelite.value);
  }
}