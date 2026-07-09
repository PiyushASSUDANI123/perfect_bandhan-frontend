import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

Future<Uint8List?> selectImage(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
  );
  
  if (pickedFile == null) return null;

  // Launch cropper
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: pickedFile.path,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Crop & Rotate',
          toolbarColor: const Color(0xFFC5A059),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
      ),
      IOSUiSettings(
        title: 'Crop & Rotate',
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
      ),
      WebUiSettings(
        context: context,
        presentStyle: WebPresentStyle.dialog,
        rotatable: true,
        zoomable: true,
      ),
    ],
  );

  if (croppedFile != null) {
    return await croppedFile.readAsBytes();
  }
  
  // If user cancels cropping, return original image bytes
  return await pickedFile.readAsBytes();
}
