import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/AIPainterModel.dart';
import 'package:sd/sd/bean/db/History.dart';

import '../../common/util/ui_util.dart';
import '../const/config.dart';
import '../http_service.dart';
import '../mocker.dart';
import '../widget/AgeLevelCover.dart';

const String TAG = "RemoteHistoryWidget";

class RemoteHistoryWidget extends StatefulWidget {
  final String dir;
  final int fnIndex;

  const RemoteHistoryWidget(this.dir, this.fnIndex, {super.key});

  @override
  State<RemoteHistoryWidget> createState() => _RemoteHistoryWidgetState();
}

class _RemoteHistoryWidgetState extends State<RemoteHistoryWidget> with AutomaticKeepAliveClientMixin{
  bool dateOrder = false;
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

    return Stack(children: [
      EasyRefresh.builder(
          refreshOnStart: true,
          controller: _controller,
          onRefresh: () async {
            pageNum = 0;
            history.clear();
            loadData(context, widget.dir, pageNum, pageSize);
          },
          onLoad: () async {
            pageNum += 1;
            loadData(context, widget.dir, pageNum, pageSize);
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
                          if (item.localPath != null) {
                            post("$sdHttpService$RUN_PREDICT",
                                    formData: delateFile(
                                        item.localPath,
                                        pageNum + 1,
                                        index % 36,
                                        history.length % 36))
                                .then((value) {
                              logt(TAG, "delete file$value");
                            });
                          }
                        },
                        onTap: () async {
                          Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER,
                              arguments: {
                                "urls": history,
                                "index": index,
                                "savePath": getWorkspacesPath(),
                              });
                        },
                        child: Selector<AIPainterModel, int>(
                          selector: (_, model) => provider.hideNSFW
                              ? model.limitedUrl(item.url!)
                              : 0,
                          builder: (context, value, child) {
                            return
                              // AgeLevelCover(item);


                              value >= 18
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
          }),
      IconButton(
          icon: dateOrder
              ? const Icon(Icons.date_range_sharp)
              : const Icon(Icons.fiber_smart_record),
          onPressed: () {
            setState(() {
              dateOrder = !dateOrder;
              pageNum = 0;
              loadData(context, widget.dir, pageNum, pageSize);
            });
          }),
    ]);
  }

  loadData(BuildContext context, String dir, int pageNum, int pageSize) {
    if (pageNum == 0) {
      history.clear();
    }
    post("$sdHttpService$RUN_PREDICT", formData: {
      "data": [
        // "F:\\sd outputs\\txt2img-images",
        dir,
        pageNum + 1,
        null,
        "",
        dateOrder ? "date" : "path_name"
      ], //data path_name
      "fn_index": widget.fnIndex,
    }, exceptionCallback: (e) {
      if (pageNum == 0) {
        _controller.finishRefresh(IndicatorResult.fail);
      } else {
        _controller.finishLoad(IndicatorResult.fail);
      }
    }).then((value) {
      List items = value!.data['data'][2] as List;
      List<History> newList = items
          .map((e) => mapToHistory(dir, 1, items.indexOf(e) + 1, e['name']))
          .toList();
      // List<History> newList2 =
      //     newList.where((element) => !history.contains(element)).toList();
      if (newList.isNotEmpty) {
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

  @override
  bool get wantKeepAlive => true;
}
