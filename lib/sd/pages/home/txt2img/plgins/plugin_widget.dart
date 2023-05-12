import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/empty_view.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../../../const/config.dart';
import '../../../../http_service.dart';

const TAG = "PluginWidget";

class PluginWidget extends StatelessWidget {
  final String prefix;
  final String modelType;
  final String nameFilePath;

  const PluginWidget(this.prefix, this.modelType, this.nameFilePath);

  @override
  Widget build(BuildContext context) {
    logt(TAG, nameFilePath);
    return FutureBuilder(
        future: get("$sdHttpService$nameFilePath"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String? data = snapshot.data?.data;
            if (null != data) {
              List<String> names = data.split('\r\n');
              if (names.isNotEmpty) {
                return GridView.builder(
                    itemCount: names.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 512 / 720),
                    itemBuilder: (context, index) {
                      AIPainterModel provider =
                          Provider.of<AIPainterModel>(context, listen: false);

                      return InkWell(
                        onTap: () =>
                            provider.switchCheckState(prefix, names[index]),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                                fit: BoxFit.fitWidth,
                                // placeholder: (context, url) {
                                //   return CachedNetworkImage(
                                //     imageUrl: getModelImageUrl(
                                //         modelType, names[index],
                                //         preview: true),
                                //   );
                                // },
                                imageUrl:
                                    getModelImageUrl(modelType, names[index]),
                                errorWidget: (_, url, data) =>
                                    CachedNetworkImage(
                                      imageUrl: placeHolderUrl(),
                                    )),
                            Positioned(
                                child: Selector<AIPainterModel, bool>(
                                    selector: (_, model) => model
                                        .checkedPlugins.keys
                                        .contains("$prefix:${names[index]}"),
                                    builder: (context, newValue, child) {
                                      return Checkbox(
                                        value: newValue,
                                        onChanged: (bool? value) {
                                          provider.switchCheckState(
                                              prefix, names[index]);
                                        },
                                      );
                                    })),
                            // IconButton(
                            //     onPressed: () {
                            //       if (provider.lastGenerate.isNotEmpty) {
                            //         post("$sdHttpService$RUN_PREDICT",
                            //                 formData: setPluginCover(
                            //                     provider.lastGenerate, 'pluginPathNoExt'),
                            //                 exceptionCallback: (e) {})
                            //             .then((value) async {});
                            //       }
                            //     },
                            //     icon: Icon(Icons.refresh)),
                            Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  color: Colors.black38,
                                  child: Text(
                                    names[index],
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    // textDirection: TextDecoration.,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ))
                          ],
                        ),
                      );
                    });
              }
            }
            return EmptyView(error: true);
          } else {
            return EmptyView();
          }
        });
  }
}
