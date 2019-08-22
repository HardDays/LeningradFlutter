import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../resources/markers.dart';

import '../../../models/oopt.dart';

import '../../../storage/repository.dart';

class MapPageBloc {

  final repository = Repository();

  bool canHide = false;
  BehaviorSubject<Oopt> infowindow;
  BehaviorSubject<bool> satelite;
  BehaviorSubject<List<Oopt>> ootp;

  MapPageBloc() {
    ootp = BehaviorSubject<List<Oopt>>();
    infowindow = BehaviorSubject<Oopt>();
    satelite = BehaviorSubject<bool>.seeded(false);
  }

  void load() async {
    await Markers().init();

    final data = await repository.getOotpList();
    ootp.sink.add(data);
    int i = 0;
    for (final point in data) {
      await repository.getArea(point.id);
      if (i % 5 == 0) {
        final updated = await repository.getOotpList();
        ootp.sink.add(updated);
      }
      i += 1;
    }
  }

  void changeMapType() {
    satelite.sink.add(!satelite.value);
  }

  void showInfoWindow(Oopt oopt) {
    canHide = false;

    infowindow.sink.add(oopt);

    //kostili attention
    Timer(Duration(seconds: 1), 
      () {
        canHide = true;
      }
    );
  }

  void hideInfoWindow() {
    if (canHide) {
      infowindow.value = null;
    }
  }
}