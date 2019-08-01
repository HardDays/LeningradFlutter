import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../resources/markers.dart';

import '../../../models/oopt.dart';

import '../../../storage/repository.dart';

class ListPageBloc {

  final repository = Repository();

  BehaviorSubject<List<Oopt>> ootp;

  ListPageBloc() {
    ootp = BehaviorSubject<List<Oopt>>();
  }

  void load() async {
    final data = await repository.getOotpList();
    ootp.sink.add(data);
  }
}