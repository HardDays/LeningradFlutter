import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../resources/app_colors.dart';

import '../../models/oopt.dart';

class Markers {

  static final Markers _singleton = Markers._internal();
  
  Markers._internal();

  factory Markers() {
    return _singleton;
  }

  final Map<String, Uint8List> mapper = {};

  // Uint8List yellowMarker;
  // Uint8List greenMarker;
  // Uint8List blueMarker;
  // Uint8List redMarker;

  Future init() async {
    mapper[OoptCategory.naturalPark] = await createMarker('assets/images/icons/pin_1.png');
    mapper[OoptCategory.naturalMonument] = await createMarker('assets/images/icons/pin_2.png');
    mapper[OoptCategory.wildlifeSanctuary] = await createMarker('assets/images/icons/pin_3.png');
    mapper['fire'] = await createMarker('assets/images/icons/pin_4.png');
  }

  Future<ui.Image> load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Uint8List marker(String name) {
    return mapper[name];
  }

  // Future createPlaceMarker() async {
  //   final radius = 23.0;
  //   final recorder = ui.PictureRecorder();
    
  //   final canvas = Canvas(recorder);
  //   canvas.drawCircle(Offset(radius, radius), radius, Paint()..color = AppColors.purple);
  //   canvas.drawCircle(Offset(radius, radius), radius - 4, Paint()..color = AppColors.yellow);

  //   final pic = recorder.endRecording();
  //   final data = await (await pic.toImage(radius.toInt() * 2, radius.toInt() * 2)).toByteData(format: ui.ImageByteFormat.png);
  //   placeMarker = data.buffer.asUint8List();
  // }

  Future<Uint8List> createMarker(String path) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final image = await load(path);
    canvas.drawImageRect(image, Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()), Rect.fromLTRB(0, 0, 100, 100), Paint());

    final pic = recorder.endRecording();
    final data = await (await pic.toImage(100, 100)).toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }
}