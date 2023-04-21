import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/empty_view.dart';
import 'package:sd/sd/AIPainterModel.dart';

import '../../http_service.dart';
import '../../config.dart';

class PluginWidget extends StatelessWidget {
  String prefix;
  String modelType;
  String nameFilePath;

  PluginWidget(this.prefix, this.modelType, this.nameFilePath);

  @override
  Widget build(BuildContext context) {
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
                            Positioned(
                                bottom: 0,
                                child: Text(
                                  names[index],
                                  style: const TextStyle(color: Colors.white),
                                ))
                          ],
                        ),
                      );
                    });
              } else {
                return EmptyView();
              }
            }
          }
          return EmptyView(error: true);
        });
  }
}
