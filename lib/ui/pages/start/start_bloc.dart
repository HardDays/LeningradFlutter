import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class StartPageBloc {
  final imageCount = 8;

  BehaviorSubject<int> image;
  BehaviorSubject<bool> loaded;

  Timer timer;

  StartPageBloc() {
    image = BehaviorSubject<int>.seeded(0);
    loaded = BehaviorSubject<bool>();

    timer = Timer.periodic(Duration(seconds: 5), 
      (t) {
        changeImage();
      }
    );
  }

  void preloadImages(BuildContext context, List<String> images) async {
    for (final image in images) {
      await precacheImage(AssetImage(image), context);
    }
    loaded.sink.add(true);
  }

  void changeImage() {
    image.sink.add((image.value + 1) % 8);
  }
  

}