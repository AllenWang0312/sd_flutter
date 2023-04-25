import 'dart:isolate';

import 'package:sd/sd/http_service.dart';

import '../third_util.dart';

class WebDownloader {
  static const String TAG="WebDownloader";

  final String url;
  final String dirPath;
  final String fileName;


  WebDownloader(this.url, this.dirPath, this.fileName);

  Future<String> downloadInBackground() async {
    final mainThreadPort = ReceivePort();
    await Isolate.spawn(_download, mainThreadPort.sendPort);
    // mainThreadPort.listen((message) async {
    //   logt(TAG,(await message).toString());
    // });
    return await mainThreadPort.first;
  }

  Future<String> _download(SendPort p) async {
    Isolate.exit(p, saveUrlToLocal(
                url, fileName, dirPath));
  }
}
