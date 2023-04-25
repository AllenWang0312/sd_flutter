import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/const/config.dart';

import '../../common/util/ui_util.dart';
import '../AIPainterModel.dart';
import '../bean/Configs.dart';
import '../tavern/bean/ImageSize.dart';
import '../tavern/bean/UniqueSign.dart';

class AgeLevelCover extends StatelessWidget {
  UniqueSign info;
  bool? needInfoLogo;

  AgeLevelCover(this.info, {this.needInfoLogo = true});

  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    File image = File(info.getLocalPath());
    Uint8List bytes = image.readAsBytesSync();

    // String sign = info.getSign(bytes);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: SHAPE_IMAGE_CARD,
      child: FutureBuilder(
        future: info.getExif(image),
        builder: (context, snapshot) {
          return Stack(
            children: [
             filterCover(provider,info,bytes),
              if (null != snapshot.data &&
                  snapshot.data!.isNotEmpty &&
                  null != needInfoLogo &&
                  needInfoLogo!)
                Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () => showPromptDialog(
                          provider, context, snapshot.data.toString()),
                      icon: const Icon(Icons.info),
                    ))
            ],
          );
        },
      ),
    );
  }


}
filterCover(AIPainterModel provider, UniqueSign info, Uint8List bytes) {
  return Selector<AIPainterModel, int>(
      selector: (_, model) =>
      provider.hideNSFW ? info.getAgeLevel(provider, bytes) : 0,
      builder: (context, value, child) {
        return value >= 18
            ? ImageFiltered(imageFilter: AGE_LEVEL_BLUR, child: child)
            : child!;
      },
      child: Expanded( // todo 有没有更好的方法
        child: Image.memory(bytes,fit: BoxFit.cover,),
      )
    // Selector<AIPainterModel, ImageSize?>(
    //   selector: (_, model) => model.imgSize[info.sign],
    //   builder: (context, value, child) {
    //     return img;
    //   },
    // ),
  );
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
