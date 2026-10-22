import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/images/image_compressor.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// A fake encoder: the lower the quality, the smaller the file.
class _FakeCompressPlatform extends FlutterImageCompressPlatform {
  _FakeCompressPlatform({this.fail = false});

  /// When true the plugin gives up (unsupported format, out of memory...).
  final bool fail;

  /// The quality of every compression attempt.
  final List<int> qualities = [];

  @override
  Future<XFile?> compressAndGetFile(
    String path,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    qualities.add(quality);
    if (fail) return null;

    // 4 KB per quality point — a q75 photo weighs ~300 KB, a q35 one ~140 KB.
    final bytes = Uint8List(quality * 4 * 1024);
    await File(targetPath).writeAsBytes(bytes);
    return XFile(targetPath);
  }

  @override
  Future<Uint8List?> compressWithFile(
    String path, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async =>
      null;

  @override
  Future<Uint8List> compressWithList(
    Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async =>
      image;

  @override
  Future<Uint8List?> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async =>
      null;

  @override
  void ignoreCheckSupportPlatform(bool bool) {}

  @override
  Future<void> showNativeLog(bool value) async {}

  @override
  FlutterImageCompressValidator get validator =>
      FlutterImageCompressValidator(MethodChannel('fake'));
}

/// Serves the temp directory of the test.
class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.directory);

  final String directory;

  @override
  Future<String?> getTemporaryPath() async => directory;

  @override
  Future<String?> getApplicationSupportPath() async => directory;

  @override
  Future<String?> getApplicationDocumentsPath() async => directory;

  @override
  Future<String?> getApplicationCachePath() async => directory;

  @override
  Future<String?> getExternalStoragePath() async => directory;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hawiah_compressor_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  Future<File> writePhoto(String name, int sizeInBytes) async {
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(Uint8List(sizeInBytes));
    return file;
  }

  test('a big photo is scaled down and stays below the size limit', () async {
    final platform = _FakeCompressPlatform();
    FlutterImageCompressPlatform.instance = platform;

    final photo = await writePhoto('photo.jpg', 4 * 1024 * 1024);
    final result = await ImageCompressor.compress(photo);

    expect(result.path, isNot(photo.path));
    expect(await result.length(), lessThanOrEqualTo(ImageCompressor.maxBytes));

    // The quality is lowered until the file fits.
    expect(platform.qualities, isNotEmpty);
    expect(platform.qualities.first, ImageCompressor.qualities.first);
  });

  test('a small photo is uploaded as it is', () async {
    final platform = _FakeCompressPlatform();
    FlutterImageCompressPlatform.instance = platform;

    final photo = await writePhoto('small.jpg', 50 * 1024);
    final result = await ImageCompressor.compress(photo);

    expect(result.path, photo.path);
    expect(platform.qualities, isEmpty);
  });

  test('a photo is kept when the compression fails', () async {
    FlutterImageCompressPlatform.instance = _FakeCompressPlatform(fail: true);

    final photo = await writePhoto('photo.jpg', 4 * 1024 * 1024);
    final result = await ImageCompressor.compress(photo);

    expect(result.path, photo.path);
  });

  test('a missing file does not break the upload', () async {
    final missing = File('${tempDir.path}/missing.jpg');
    final result = await ImageCompressor.compress(missing);

    expect(result.path, missing.path);
  });
}
