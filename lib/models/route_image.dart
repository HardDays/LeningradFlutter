import 'dart:typed_data';

class RouteImage {
  Uint8List data;
  Uint8List compressedData;

  RouteImage(this.data, this.compressedData);
}