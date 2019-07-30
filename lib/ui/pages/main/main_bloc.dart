import 'package:rxdart/rxdart.dart';

class MainPageBloc {
  BehaviorSubject<int> page;

  MainPageBloc() {
    page = BehaviorSubject<int>.seeded(0);

  }

  void changePage(int page) {
    this.page.sink.add(page);
  }
}