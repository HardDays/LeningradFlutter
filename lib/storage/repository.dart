import '../models/oopt.dart';

import '../providers/oopt_provider.dart';

class Repository {

  static final Repository _singleton = Repository._internal();
  
  Repository._internal();

  factory Repository() {
    return _singleton;
  }

  List<Oopt> cachedOopt;

  Future<List<Oopt>> getOotpList() async {
    if (cachedOopt == null) {
      cachedOopt = await OoptProvider.loadList();
    }
    return cachedOopt;
  }

  String getOotpLink(int id) {
    return OoptProvider.htmlLink(id);
  }

}