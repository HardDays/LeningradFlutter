import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../resources/markers.dart';

import '../../../models/place.dart';

import '../../../storage/repository.dart';

class RouteListPageBloc {

  final repository = Repository();

  BehaviorSubject<List<Place>> places;

  RouteListPageBloc() {
    places = BehaviorSubject<List<Place>>();
  }

  void load(int id) async {
    final res = await repository.getRoutePlaces(id);
    places.sink.add(res);
  }

 
}