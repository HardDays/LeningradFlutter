import 'dart:async';

import 'package:rxdart/rxdart.dart';

class StartPageBloc {
  final imageCount = 8;

  BehaviorSubject<int> image;
  Timer timer;

  StartPageBloc() {
    image = BehaviorSubject<int>.seeded(0);
    timer = Timer.periodic(Duration(seconds: 5), 
      (t) {
        changeImage();
      }
    );
  }

  void changeImage() {
    image.sink.add((image.value + 1) % 8);
  }
  

}