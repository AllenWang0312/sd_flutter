import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/widget/file_prompt_reader.dart';

import '../../common/third_util.dart';
import '../../common/util/ui_util.dart';
import '../bean/Configs.dart';
import '../bean/file/UniqueSign.dart';
import '../http_service.dart';
import '../provider/AIPainterModel.dart';

const TAG = 'AgeLevelCover';

class AgeLevelCover extends StatelessWidget with FilePromptReader {
  UniqueSign info;
  bool? needInfoLogo;

  AgeLevelCover(this.info, {super.key, this.needInfoLogo = true});

  late AIPainterModel provider;

  Configs? configs;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    String fileLocation = info.getFileLocation();
    logt(TAG, "fileLocation" + fileLocation);
    if (fileLocation.startsWith("http") && fileLocation.endsWith(".png")) {
      // bytes = await getBytesWithDio(info.url!);
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: SHAPE_IMAGE_CARD,
        child: FutureBuilder(
          future: getBytesWithDio(info.getFileLocation()!),
          builder: (context, snapshot) {
            return Stack(
              children: [
                filterCover(provider, info),
                Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () => showPromptDialog(provider, context,
                          getPNGExtData(snapshot.data!) ?? ""),
                      icon: const Icon(Icons.info),
                    ))
              ],
            );
          },
        ),
      );
    } else {
      File image = File(info.getFileLocation());
      // Uint8List bytes= image.readAsBytesSync();
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: SHAPE_IMAGE_CARD,
        child: FutureBuilder(
          future: info.getAndCacheExif(image),
          builder: (context, snapshot) {
            if (null != snapshot.data) {
              configs = pauseConfigs(snapshot.data.toString());
            }
            return Stack(
              children: [
                filterCover(provider, info),
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
                      )),
                if (configs != null)
                  Positioned(
                      left: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          Text(configs?.model ?? '未读取到主模'),
                          Text('高 ${configs?.height} 宽 ${configs?.width}')
                        ],
                      )),
              ],
            );
          },
        ),
      );
    }

    // String sign = info.getSign(bytes);
  }
}

filterCover(AIPainterModel provider, UniqueSign info) {
  return Selector<AIPainterModel, int>(
      selector: (_, model) =>
          provider.hideNSFW ? provider.getAgeLevel(info.uniqueTag()) : 0,
      builder: (context, value, child) {
        return value >= 18
            ? ImageFiltered(imageFilter: AGE_LEVEL_BLUR, child: child)
            : child!;
      },
      child: SizedBox.expand(child: Image.file(File(info.getFileLocation())))
      // Selector<AIPainterModel, ImageSize?>(
      //   selector: (_, model) => model.imgSize[info.sign],
      //   builder: (context, value, child) {
      //     return img;
      //   },
      // ),
      );
}
