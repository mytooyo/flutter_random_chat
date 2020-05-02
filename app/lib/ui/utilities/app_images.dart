
import 'dart:io';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;


Future<File> fixExifRotation(String imagePath) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    // We'll use the exif package to read exif data
    // This is map of several exif properties
    // Let's check 'Image Orientation'
    final exifData = await readExifFromBytes(imageBytes);

    img.Image fixedImage;

    if (exifData['Image Orientation'] == null) {
      fixedImage = originalImage;
    }
    else {
      // rotate
      if (exifData['Image Orientation'].printable.contains('270')) {
        fixedImage = img.copyRotate(originalImage, 90);
      } else if (exifData['Image Orientation'].printable.contains('90')) {
        fixedImage = img.copyRotate(originalImage, -90);
      } else if (exifData['Image Orientation'].printable.contains('180')) {
        fixedImage = img.copyRotate(originalImage, 180);
      } else {
        fixedImage = img.copyRotate(originalImage, 0);
      }
    }
    // Here you can select whether you'd like to save it as png
    // or jpg with some compression
    // I choose jpg with 100% quality
    final fixedFile =
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

    return fixedFile;
  }