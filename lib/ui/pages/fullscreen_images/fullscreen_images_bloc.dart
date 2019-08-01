import 'package:rxdart/rxdart.dart';

import '../../../storage/repository.dart';

class FullscreenImagesBloc {

  final repository = Repository();

  BehaviorSubject<int> currentImage;

  FullscreenImagesBloc() {
    currentImage = BehaviorSubject<int>.seeded(0);
  }

  void changeImage(int image) async {
    currentImage.sink.add(image);
  }

}