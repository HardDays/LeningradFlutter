import 'package:rxdart/rxdart.dart';

import '../../../storage/repository.dart';

class OoptPageBloc {

  final repository = Repository();

  BehaviorSubject<int> currentImage;

  OoptPageBloc() {
    currentImage = BehaviorSubject<int>.seeded(0);
  }

  void changeImage(int image) async {
    currentImage.sink.add(image);
  }

}