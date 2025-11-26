import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:photo_view/photo_view.dart';

import '../custom_loading/custom_loading.dart';

class ZoomImageArgs {
  final String? imageUrl;
  final File? imageFile;

  const ZoomImageArgs({this.imageUrl, this.imageFile});
}

class ZoomImageScreen extends StatefulWidget {
  final ZoomImageArgs args;
  const ZoomImageScreen({super.key, required this.args});

  static const String routeName = 'ZoomImageScreen';

  @override
  State<ZoomImageScreen> createState() => _ZoomImageScreenState();
}

class _ZoomImageScreenState extends State<ZoomImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   context,
      //   centerTitle: false,
      //   automaticallyImplyLeading: true,
      //   radius: 0,
      // ),
      body: PhotoView(
        imageProvider: _imageProvider(),
        loadingBuilder: (context, event) {
          return const Center(child: CustomLoading());
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Image.asset(AppImages.logoIcon));
        },
      ),
    );
  }

  ImageProvider? _imageProvider() {
    if (widget.args.imageUrl != null) {
      return NetworkImage(widget.args.imageUrl!);
    } else if (widget.args.imageFile != null) {
      return FileImage(widget.args.imageFile!);
    }
    return null;
  }
}
