import 'dart:async';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveFile(List<int> bytes, String fileName, String mimeType) async {
  final directory = await getTemporaryDirectory();
  final file = io.File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(file.path)], text: fileName);
}
