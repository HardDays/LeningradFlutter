import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../resources/markers.dart';

import '../../../models/oopt.dart';

import '../../../storage/repository.dart';

class ListPageBloc {

  final repository = Repository();

  List<Oopt> loaded;

  BehaviorSubject<List<Oopt>> oopt;
  BehaviorSubject<List<Uint8List>> compressedImages;

  ListPageBloc() {
    oopt = BehaviorSubject<List<Oopt>>();
    compressedImages = BehaviorSubject<List<Uint8List>>();
  }

  void load() async {
    final data = await repository.getOotpList();
    loaded = List.from(data);
    loaded.sort((o1, o2) => o1.name.compareTo(o2.name));
    oopt.sink.add(loaded);

    final images = await repository.getCompressedImages(loaded);
    compressedImages.sink.add(images);
  }

  void search(String text) {
    oopt.sink.add(loaded.where((p) => p.name.toLowerCase().contains(text.toLowerCase())).toList());
  }
}