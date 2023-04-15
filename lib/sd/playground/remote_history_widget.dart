import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd/sd/bean/db/History.dart';
import 'package:sd/sd/file_util.dart';
import 'package:sd/sd/ui_util.dart';

import '../config.dart';
import '../http_service.dart';
import '../mocker.dart';
import 'abs_gallery_widget.dart';

class RemoteHistoryWidget extends GalleryWidget {

  bool dateOrder = true;

  final TAG = "HistoryWidget";

  List<History> history = [];
  int viewType = 0; //list grid flot scale

  late EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
        controller: _controller,
        onRefresh: () async {
          pageNum = 0;
          history.clear();
          loadData(pageNum, pageSize);
        },
        onLoad: () async {
          pageNum += 1;
          loadData(pageNum, pageSize);
        },
        childBuilder: (context, physics) {
          return MasonryGridView.count(
            physics: physics,
            itemCount: history.length,
            itemBuilder: (context, index) {
              // History item = History.fromJson(snapshot.data![index]);
              History item = history[index];
              return item.imgUrl != null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER,
                            arguments: {
                              "urls": history,
                              "index": index,
                              "pageSize": 36,
                              "pageNum": index / 36,
                              "saveDirPath": getAutoSaveAbsPath()
                            });
                      },
                      onLongPress: () async {
                        if (item.imgPath != null) {
                          int deleteResult = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("确认删除"),
                                    content: Text("点击确认删除文件${item.imgPath}"),
                                    actions: [
                                      TextButton(
                                          onPressed: () => {
                                                post(
                                                    "$sdHttpService$RUN_PREDICT",
                                                    formData: delateFile(
                                                        item.imgPath!,
                                                        item.page!,
                                                        item.offset!),
                                                    exceptionCallback: (e) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          '删除失败${e.toString()}');
                                                  Navigator.pop(context, -1);
                                                }).then((value) {
                                                  logt(TAG, value.toString());
                                                  Navigator.pop(context, 1);
                                                })
                                              },
                                          child: Text('确认'))
                                    ],
                                  ));
                          if (deleteResult == 1) {
                            //todo 删除item 并刷新
                          }
                        }
                      },
                      child: userAge >= item.ageLevel
                          ? Card(
                              clipBehavior: Clip.antiAlias,
                              shape: SHAPE_IMAGE_CARD,
                              child: CachedNetworkImage(
                                imageUrl: item.imgUrl!,
                              ),
                            )
                          : ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                  sigmaX: 2,
                                  sigmaY: 2,
                                  tileMode: TileMode.decal),
                              child: CachedNetworkImage(
                                imageUrl: item.imgUrl!,
                              ),
                            ))
                  : Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 160,
                          child: Image.file(File(item.imgPath!)),
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

  loadData(int pageNum, int pageSize) {
    // widget.db.queryHistorys(pageNum, pageSize)?.then((value) {
    //   setState(() {
    //     history.addAll(value.map((e) => History.fromJson(e)).toList());
    //   });
    //   print(HistoryWidget.TAG + history.length.toString());
    //   return IndicatorResult.success;
    // });
    if (pageNum == 0) {
      _controller.callRefresh();
    } else {
      _controller.callLoad();
    }

    //todo 动态获取文件路径
    post("$sdHttpService$RUN_PREDICT", formData: {
      "data": [
        "F:\\sd outputs\\txt2img-images",
        pageNum + 1,
        null,
        "",
        dateOrder ? "date" : "path_name"
      ], //data path_name
      "fn_index": CMD_GET_REMOTE_HISTORY
    }, exceptionCallback: (e) {
      if(pageNum ==0){
        _controller.finishRefresh(IndicatorResult.fail);
      }else{
        _controller.finishLoad(IndicatorResult.fail);
      }
    }).then((value) {
      List items = value!.data['data'][2] as List;
      logd(items.toString());
      // setState(() {
      history.addAll(items
          .map(
              (e) => mapToHistory(pageNum + 1, items.indexOf(e) + 1, e['name']))
          .toList());
      // });
      if (pageNum == 0) {
        _controller.finishRefresh();
        _controller.resetFooter();
      } else if (items.length == 36) {
        _controller.finishLoad(IndicatorResult.success);
      } else {
        _controller.finishLoad(IndicatorResult.noMore);
      }
    });
  }
}
