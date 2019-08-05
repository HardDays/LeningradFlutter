import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../resources/markers.dart';

import '../../../models/place.dart';
import '../../../models/route.dart';

import '../../../storage/repository.dart';

class RouteListPageBloc {

  final repository = Repository();

  BehaviorSubject<List<Place>> places;
  BehaviorSubject<List<Point>> polyline;

  RouteListPageBloc() {
    places = BehaviorSubject<List<Place>>();
    polyline = BehaviorSubject<List<Point>>();
  }

  void load(Route route) async {
    final placeRes = await repository.getRoutePlaces(route.id);
    try {
      if (placeRes.length > 1) {
        final polyRes = await repository.getRoutePolyline(route.id, placeRes);
        final decoded = PolylinePoints().decodePolyline(polyRes).map((p) => Point(p.latitude, p.longitude)).toList();
        polyline.sink.add(decoded);
      } else {
        polyline.sink.add(placeRes.map((p) => Point(p.lat, p.lng)).toList());
      }
    } catch (ex) {
      polyline.sink.add(placeRes.map((p) => Point(p.lat, p.lng)).toList());
    }
    places.sink.add(placeRes);
  }

 
}