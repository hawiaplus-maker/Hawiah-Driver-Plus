import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hawiah_driver/core/custom_widgets/choose_gallery_or_camera_bottom_sheet.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:image_picker/image_picker.dart';

class ImageMethods {
  static Future<void> pickImage({
    required ImageSource source,
    required void Function(File) onSuccess,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      File result = File(pickedImage.path);
      onSuccess.call(result);
    }
  }

  /// Picks an image and returns it.
  ///
  /// `null` is returned when the driver cancelled the picker — the caller can
  /// then stop the flow instead of waiting for a callback that never comes.
  static Future<File?> pickImageAndReturn({
    required ImageSource source,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);
    if (pickedImage == null) return null;
    return File(pickedImage.path);
  }

  static Future<void> pickMultiImage({
    required void Function(List<File>) onSuccess,
  }) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImage = await picker.pickMultiImage();
    final List<File> result = pickedImage.map((e) => File(e.path)).toList();
    onSuccess.call(result);
  }

  static void pickImageBottomSheet(
    BuildContext context, {
    required void Function(File) onSuccess,
  }) {
    NavigatorMethods.showAppBottomSheet(
      context,
      ChooseGalleryOrCameraBottomSheet(
        onCamera: () => ImageMethods.pickImage(
          source: ImageSource.camera,
          onSuccess: onSuccess,
        ),
        onGallery: () => ImageMethods.pickImage(
          source: ImageSource.gallery,
          onSuccess: onSuccess,
        ),
      ),
    );
  }
}
