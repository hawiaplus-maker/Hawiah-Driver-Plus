import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Prepares the photos before they are uploaded to the API.
///
/// A camera photo weighs 3-8 MB, which is a lot to push over a weak mobile
/// connection — and the backend only needs a proof that shows the container.
/// The image is therefore scaled down, converted to JPEG and, when it is
/// still too heavy, the quality is lowered step by step until the file fits
/// into [maxBytes].
class ImageCompressor {
  /// The largest edge of the compressed image.
  ///
  /// `minWidth`/`minHeight` of the plugin behave like a *maximum* bound: the
  /// photo is scaled down until its short edge matches this value, the long
  /// edge keeps the aspect ratio of the photo.
  static const int maxEdge = 1080;

  /// The compressed image must stay below this size.
  static const int maxBytes = 200 * 1024;

  /// The quality steps used while the compressed image is still too heavy.
  static const List<int> qualities = [75, 65, 55, 45, 35];

  /// Compresses [file] and returns the file that has to be uploaded.
  ///
  /// The original file is returned when it is already small enough or when
  /// the compression fails — a photo must never be lost because of it.
  static Future<File> compress(
    File file, {
    String prefix = 'compressed',
  }) async {
    if (!await file.exists()) return file;

    final length = await file.length();
    final extension = path.extension(file.path).toLowerCase();
    final isJpeg = extension == '.jpg' || extension == '.jpeg';

    // A small JPEG is uploaded as it is. A small HEIC/PNG still goes through
    // the compressor so the API always receives a JPEG.
    if (length <= maxBytes && isJpeg) return file;

    final dir = await getTemporaryDirectory();
    final created = <File>[];

    try {
      File? best;

      for (final quality in qualities) {
        final target = File(
          path.join(
            dir.absolute.path,
            '${prefix}_${DateTime.now().microsecondsSinceEpoch}.jpg',
          ),
        );
        created.add(target);

        // Every attempt starts from the original photo: compressing an
        // already compressed file would only add artifacts.
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          target.absolute.path,
          minWidth: maxEdge,
          minHeight: maxEdge,
          quality: quality,
          format: CompressFormat.jpeg,
          keepExif: false,
          autoCorrectionAngle: true,
        );

        // The plugin gave up (unsupported format, out of memory...) — the
        // original photo is uploaded instead.
        if (compressed == null) break;

        final result = File(compressed.path);
        final resultLength = await result.length();

        if (best == null || resultLength < await best.length()) {
          best = result;
        }

        if (resultLength <= maxBytes) break;
      }

      // Only the uploaded file is kept, the intermediate ones are dropped.
      for (final createdFile in created) {
        if (best != null && createdFile.path == best.path) continue;
        try {
          if (await createdFile.exists()) await createdFile.delete();
        } catch (_) {
          // A file that can't be removed is not a reason to fail the upload.
        }
      }

      return best ?? file;
    } catch (_) {
      return file;
    }
  }
}
