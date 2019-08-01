import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';

import '../../../storage/repository.dart';

class FirePageBloc {

  final repository = Repository();
  final geolocator = Geolocator();

  BehaviorSubject<Position> position;

  FirePageBloc() {
    position =  BehaviorSubject<Position>();
  }

  void load() async {
    final status = await geolocator.checkGeolocationPermissionStatus();
    final enabled = await geolocator.isLocationServiceEnabled();
    if (status == GeolocationStatus.granted && enabled) {
      final point = await geolocator.getCurrentPosition();
      position.sink.add(point);
    }

  }

  void readMessage() {
    repository.readFireMessage = true;
  }

}