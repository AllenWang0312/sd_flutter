import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sd/sd/bean/db/History.dart';
import 'package:sd/sd/config.dart';
import 'package:sd/sd/db_controler.dart';

import '../../android.dart';
import '../ui_util.dart';

class HistoryWidget extends StatefulWidget {
  static const TAG = "HistoryWidget";

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  int userAge = 16;

  int pageNum = 0;

  int pageSize = 20;

  List<History> history = [];

  int viewType = 0;

  //list grid flot scale
  bool dateOrder = true;

  bool asc = false;

  late EasyRefreshController _controller;

  @override
  Widget build(BuildContext context) {
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
          loadData(pageNum, pageSize, dateOrder, asc);
        },
        onLoad: () async {
          pageNum += 1;
          loadData(pageNum, pageSize, dateOrder, asc);
        },
        childBuilder: (context, physics) {
          return MasonryGridView.count(
            physics: physics,
            itemCount: history.length,
            itemBuilder: (context, index) {
              // History item = History.fromJson(snapshot.data![index]);
              History item = history[index];
              var file = File(dbString(item.imgPath!));
              if (file.existsSync()) {
                return InkWell(
                 onTap: (){
                   Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER,
                       arguments: {"urls": history.sublist(index,min(history.length,index+20)), "index": index,"savePath":ANDROID_PUBLIC_PICTURES_PATH});

                 },
                  child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: SHAPE_IMAGE_CARD,
                      child: Image.file(file)),
                );
              } else {
                return CachedNetworkImage(imageUrl: placeHolderUrl());
              }
              // todo 暂时兼容脏数据  发版不需要dbString
            },
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          );
        });
  }

  loadData(int pageNum, int pageSize, bool dateOrder, bool asc,
      {bool filterNotExist = true}) {
    if (pageNum == 0) {
      history.clear();
    }
    DBController.instance
        .queryHistorys(pageNum, pageSize,
            order: dateOrder ? History.ORDER_BY_TIME : History.ORDER_BY_PATH,
            asc: asc)
        ?.then((value) {
      // setState(() {
      var list = value.map((e) => History.fromJson(e)).toList();

      if (filterNotExist) {
        list.removeWhere((element) =>
            element.imgPath == null || !File(element.imgPath!).existsSync());
      }

      if (list.length > 0) {
        setState(() {
          history.addAll(list);
        });
        if (pageNum == 0) {
          _controller.finishRefresh();
        } else {
          _controller.finishLoad(IndicatorResult.success);
        }
      } else {
        _controller.finishLoad(IndicatorResult.noMore);
      }
    });
  }
}
