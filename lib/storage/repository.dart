import 'dart:typed_data';

import '../models/oopt.dart';

import '../providers/oopt_provider.dart';

class Repository {

  static final Repository _singleton = Repository._internal();
  
  Repository._internal();

  factory Repository() {
    return _singleton;
  }

  bool readFireMessage = false;

  List<Oopt> cachedOopt;

  List<Uint8List> cachedCompressedImages;

  Future<List<Oopt>> getOotpList() async {
    if (cachedOopt == null) {
      cachedOopt = await OoptProvider.loadList();
    }
    return cachedOopt;
  }

  Future<List<Uint8List>> getCompressedImages(List<Oopt> oopt) async {
    if (cachedCompressedImages == null) {
      cachedCompressedImages = await OoptProvider.compressImages(oopt);
    }
    return cachedCompressedImages;
  }

}