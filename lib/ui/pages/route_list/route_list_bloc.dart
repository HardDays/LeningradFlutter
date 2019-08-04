import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../resources/markers.dart';

import '../../../models/route.dart';

import '../../../storage/repository.dart';

class RouteListPageBloc {

  final repository = Repository();

  BehaviorSubject<List<Route>> routes;

  RouteListPageBloc() {
    routes = BehaviorSubject<List<Route>>();
  }

  void load() async {
    final res = await repository.getRoutes();
    routes.sink.add(res);
  }

 
}