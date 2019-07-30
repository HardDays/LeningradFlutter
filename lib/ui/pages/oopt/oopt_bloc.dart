import 'package:rxdart/rxdart.dart';

import '../../../storage/repository.dart';

class OoptPageBloc {

  final repository = Repository();

  BehaviorSubject<String> html;

  OoptPageBloc() {
    html = BehaviorSubject<String>();
  }

  void load(int id) async {
  
  }

}