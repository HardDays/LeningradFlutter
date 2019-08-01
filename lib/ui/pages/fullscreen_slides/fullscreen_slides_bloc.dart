import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../models/oopt.dart';
import '../../../models/oopt_image.dart';

import '../../../storage/repository.dart';

class FullscreenSlidesBloc {

  final repository = Repository();

  Map<OoptImage, Oopt> ooptImages = {};

  BehaviorSubject<int> currentImage;
  BehaviorSubject<List<OoptImage>> images;
  BehaviorSubject<bool> play;
  
  FullscreenSlidesBloc() {
    currentImage = BehaviorSubject<int>.seeded(0);
    images = BehaviorSubject<List<OoptImage>>();
    play = BehaviorSubject<bool>.seeded(true);

    // timer = Timer.periodic(Duration(seconds: 3), 
    //   (t) {
    //     if (play.value) {
    //       changeImage((currentImage.value + 1) % images.value.length);
    //     }
    //   }
    // );
  }

  void load() async {
    final oopt = await repository.getOotpList();
    final shuffled = List<Oopt>.from(oopt)..shuffle();

    List<OoptImage> res = [];
    for (final oopt in shuffled) {
      for (final image in oopt.images) {
        ooptImages[image] = oopt;
      }
      res.addAll(oopt.images);
    }
    images.sink.add(res);
  }

  void changeImage(int image) async {
    currentImage.sink.add(image);
  }

  void changePlay(bool value) {
    play.sink.add(value);
  }

}