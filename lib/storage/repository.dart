import 'dart:typed_data';

import 'package:google_maps_webservice/directions.dart' as dir;

import '../models/oopt.dart';
import '../models/route.dart';
import '../models/place.dart';

import '../providers/oopt_provider.dart';
import '../providers/routes_provider.dart';
import '../providers/graphopper_provider.dart';

class Repository {

  static final Repository _singleton = Repository._internal();
  
  Repository._internal();

  factory Repository() {
    return _singleton;
  }

  final googleRoutes = dir.GoogleMapsDirections(apiKey: 'AIzaSyCwkF3xcHqNUOCfZGlvIyzjouNmpdPXOiA');

  bool readFireMessage = false;

  List<Oopt> cachedOopt;
  List<Route> cachedRoutes;
  Map<int, List<Place>> cachedRoutePlaces = {};
  Map<int, String> cachedPolylines = {};

  List<Uint8List> cachedCompressedImages;

  Future<List<Oopt>> getOotpList() async {
    if (cachedOopt == null) {
      cachedOopt = await OoptProvider.loadList();
    }
    return cachedOopt;
  }

  Future<List<Uint8List>> getCompressedImages(List<Oopt> oopt) async {
    if (cachedCompressedImages == null) {
      cachedCompressedImages = await OoptProvider.compressImages(oopt);
    }
    return cachedCompressedImages;
  }

  Future<List<Route>> getRoutes() async {
    if (cachedRoutes == null) {
      cachedRoutes = await RoutesProvider.getRoutes();
    }
    return cachedRoutes;
  }

  Future getArea(int id) async {
    for (final oopt in cachedOopt) {
      if (oopt.id == id) {
        final area = await OoptProvider.loadArea(oopt.id);
        oopt.points = area;
      }
    }
  }


  Future<List<Place>> getRoutePlaces(int id) async {
    if (!cachedRoutePlaces.containsKey(id)) {
      cachedRoutePlaces[id] = await RoutesProvider.getRoutePlaces(id);
      //cachedRoutePlaces[id].add(Place(lat: cachedRoutePlaces[id].last.lat + 0.1, lng: cachedRoutePlaces[id].last.lng + 0.1));
      //cachedRoutePlaces[id].add(Place(lat: cachedRoutePlaces[id].last.lat + 0.05, lng: cachedRoutePlaces[id].last.lng - 0.1));

    }
    return cachedRoutePlaces[id];
  }

  Future<String> getRoutePolyline(int id, List<Place> places) async {
    if (!cachedPolylines.containsKey(id)) {
      dir.DirectionsResponse res;
//      if (places.length > 2) {
//        res = await googleRoutes.directionsWithLocation(dir.Location(places.first.lat, places.first.lng), dir.Location(places.last.lat, places.last.lng),
//          waypoints: places.sublist(1, places.length - 1).map((p) => dir.Waypoint.fromLocation(dir.Location(p.lat, p.lng))).toList(),
//          travelMode: dir.TravelMode.walking
//        );
//      } else {
//        res = await googleRoutes.directionsWithLocation(dir.Location(places.first.lat, places.first.lng), dir.Location(places.last.lat, places.last.lng), travelMode: dir.TravelMode.walking);
//      }
      if (res.status == 'OK') {
        cachedPolylines[id] =  await GraphhopperProvider.getRoute(places); //res.routes.first.overviewPolyline.points;
      }
    }
    return cachedPolylines[id];
  }
}