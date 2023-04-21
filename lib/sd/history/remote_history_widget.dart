import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/sd/bean/db/History.dart';
import 'package:sd/sd/AIPainterModel.dart';

import '../../common/util/ui_util.dart';
import '../config.dart';
import '../http_service.dart';
import '../mocker.dart';

const String TAG = "RemoteHistoryWidget";

class RemoteHistoryWidget extends StatefulWidget {
  @override
  State<RemoteHistoryWidget> createState() => _RemoteHistoryWidgetState();
}

class _RemoteHistoryWidgetState extends State<RemoteHistoryWidget> {
  bool dateOrder = true;

  int pageNum = 0;

  int pageSize = 20;

  List<History> history = [];

  int viewType = 0;

  //list grid flot scale
  late EasyRefreshController _controller;
  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);

    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    return EasyRefresh.builder(
        refreshOnStart: true,
        controller: _controller,
        onRefresh: () async {
          pageNum = 0;
          history.clear();
          loadData(context, pageNum, pageSize);
        },
        onLoad: () async {
          pageNum += 1;
          loadData(context, pageNum, pageSize);
        },
        childBuilder: (context, physics) {
          return MasonryGridView.count(
            physics: physics,
            itemCount: history.length,
            itemBuilder: (context, index) {
              logt(TAG, "create item $index");
              // History item = History.fromJson(snapshot.data![index]);
              History item = history[index];
              return item.url != null
                  ? GestureDetector(
                      onLongPress: () async {
                        if (item.localPath != null) {}
                      },
                      onTap: () async {
                        Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER,
                            arguments: {
                              "urls": history,
                              "index": index,
                              "savePath": await getImageAutoSaveAbsPath(),
                            });
                      },
                      child: Selector<AIPainterModel, int>(
                        selector: (_, model) => provider.hideNSFW?model.limitedUrl(item.url!):0,
                        builder: (context, value, child) {
                          return value>=18
                              ? ClipRect(
                                  child: ImageFiltered(
                                    imageFilter: AGE_LEVEL_BLUR,
                                    child: CachedNetworkImage(
                                      imageUrl: item.url!,
                                    ),
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: item.url!,
                                );
                        },
                      ))
                  : Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 160,
                          child: Image.file(File(item.localPath!)),
                        )
                      ],
                    );
            },
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          );
        });
  }

  loadData(BuildContext context, int pageNum, int pageSize) {
    if (pageNum == 0) {
      history.clear();
    }
    //todo 动态获取文件路径
    post("$sdHttpService$RUN_PREDICT", formData: {
      "data": [
        // "F:\\sd outputs\\txt2img-images",
        remoteTXT2IMGDir,
        pageNum + 1,
        null,
        "",
        dateOrder ? "date" : "path_name"
      ], //data path_name
      "fn_index": CMD_GET_REMOTE_HISTORY
    }, exceptionCallback: (e) {
      if (pageNum == 0) {
        _controller.finishRefresh(IndicatorResult.fail);
      } else {
        _controller.finishLoad(IndicatorResult.fail);
      }
    }).then((value) {
      List items = value!.data['data'][2] as List;
      List<History> newList = items
          .map(
              (e) => mapToHistory(pageNum + 1, items.indexOf(e) + 1, e['name']))
          .toList();
      // List<History> newList2 =
      //     newList.where((element) => !history.contains(element)).toList();
      if (newList.length > 0) {
        setState(() {
          history.addAll(newList);
        });
        if (pageNum == 0) {
          _controller.finishRefresh();
        } else {
          _controller.finishLoad(IndicatorResult.success);
        }
      } else {
        logt(TAG, "nomore");
        _controller.finishLoad(IndicatorResult.noMore);
      }
    });
  }
}
