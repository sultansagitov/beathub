import 'package:flutter/cupertino.dart';

class ImageAlbum {
  String name;
  AssetImage image;

  ImageAlbum(this.name, String imagePath) : image = AssetImage(imagePath);

}