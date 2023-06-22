import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;

import '../const/routes.dart';
import '../provider/AIPainterModel.dart';

String? getPNGExtData(Uint8List bytes) {
  var chunks = pngExtract.extractChunks(bytes);
  var scanChunkName = "tEXt";
  for (Map chunk in chunks) {
    for (String key in chunk.keys) {
      if (chunk[key].toString() == scanChunkName) {
        return String.fromCharCodes(chunk['data']);
      }
    }
  }
  return null;
}
Future<void> showPromptDialog(
    AIPainterModel provider, BuildContext context, String prompt) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Prompt'),
          content: SingleChildScrollView(child: SelectableText(prompt)),
          actions: [
            TextButton(
                onPressed: () {
                  provider.updatePrompt(prompt);
                  // provider.updateConfigs(Configs.fromString(prompt));
                  // 跳转使用
                  Navigator.pushNamedAndRemoveUntil(
                      context, ROUTE_HOME, (route) => false,
                      arguments: {"index": 1});
                  // Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: ),(route)=>false);
                },
                child: Text('立即使用')),
            TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: prompt));
                },
                child: Text('复制'))
          ],
        );
      });
  // provider.updateIndex(result);
}
class FilePromptReader {

}
