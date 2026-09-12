import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';

/// Returns a small PNG for storage, or null when the user cancels the picker.
Future<Uint8List?> pickProfileLogo() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg'],
  );
  if (file == null) return null;
  if (await file.length() >= 20 * 1024 * 1024 ||
      !['png', 'jpg', 'jpeg'].contains(file.extension?.toLowerCase())) {
    throw const FormatException('Choose a PNG or JPG smaller than 20 MB.');
  }
  final codec = await ui.instantiateImageCodec(
    await file.readAsBytes(),
    targetWidth: 512,
  );
  try {
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    if (data == null) throw StateError('Invalid image');
    return data.buffer.asUint8List();
  } finally {
    codec.dispose();
  }
}
