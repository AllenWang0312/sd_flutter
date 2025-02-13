import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:sd/sd/bean/db/History.dart';
import 'package:sd/sd/const/routes.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/history/PageListState.dart';
import 'package:sd/sd/widget/age_level_cover.dart';

import '../http_service.dart';
import '../widget/PageListViewer.dart';

const TAG = "HistoryWidget";

class HistoryWidget extends PageListViewer {
  // HistoryWidget({super.key});

  bool asc = false;

  _HistoryWidgetState state = _HistoryWidgetState();

  @override
  State<HistoryWidget> createState() => state;

  @override
  void returnTopAndRefresh() {
    state.scroller.jumpTo(0);

    if (pageNum > 0) {
      pageNum = 0;
      state.loadData(pageNum, pageSize, dateOrder, asc);
    }

    // state._controller.callRefresh()
  }
}

class _HistoryWidgetState extends PageListState<HistoryWidget>
    with AutomaticKeepAliveClientMixin {
  List<History> history = [];

  int viewType = 0;

  //list grid flot scale

  @override
  Widget build(BuildContext context) {
    controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    scroller = ScrollController();
    return EasyRefresh.builder(
        refreshOnStart: true,
        controller: controller,
        onRefresh: () async {
          widget.pageNum = 0;
          history.clear();
          loadData(
              widget.pageNum, widget.pageSize, widget.dateOrder, widget.asc);
        },
        onLoad: () async {
          if (history.isNotEmpty && history.length % widget.pageSize == 0) {
            widget.pageNum += 1;
            loadData(
                widget.pageNum, widget.pageSize, widget.dateOrder, widget.asc);
          }
        },
        childBuilder: (context, physics) {
          return GridView.builder(
            physics: physics,
            controller: scroller,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 512/768
                // 512 / 768
                ),
            itemCount: history.length,
            itemBuilder: _itemBuilder,
          );

          // return MasonryGridView.count(
          //   physics: physics,
          //   controller: _scroller,
          //   itemCount: history.length,
          //   itemBuilder: _itemBuilder,
          //   crossAxisCount: 2,
          //   mainAxisSpacing: 2,
          //   crossAxisSpacing: 2,
          // );
        });
  }

  loadData(int pageNum, int pageSize, bool dateOrder, bool asc,
      {bool filterNotExist = false}) {
    if (pageNum == 0) {
      history.clear();
    }
    DBController.instance
        .queryHistorys(pageNum, pageSize, asc: asc)
        .then((value) {
      // setState(() {
      if (null != value) {
        List<History> list = value.map((e) => History.fromJson(e)).toList();
        // logt(TAG,list.toString());
        if (filterNotExist) {
          list.removeWhere((element) =>
              element.localPath == null ||
              !File(element.localPath!).existsSync());
        }
        setState(() {
          logt(TAG, list.map((e) => e.getFileLocation()).toList().toString());

          history.addAll(list);
        });
      }
      controller.finishRefresh(
          pageNum == 0 ? IndicatorResult.success : IndicatorResult.noMore);
      controller.finishLoad(value?.length == 36
          ? IndicatorResult.success
          : IndicatorResult.noMore);
    });
  }

  @override
  bool get wantKeepAlive => true;

  Widget _itemBuilder(BuildContext context, int index) {
    // History item = History.fromJson(snapshot.data![index]);
    History item = history[index];
    // Uri uri = Uri.file(item.localPath!);
    // File(uri.ab);

    // File file = File(item.localPath!);
    // AIPainterModel provider = Provider.of<AIPainterModel>(context);
    return InkWell(
        onTap: () async {
          Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER, arguments: {
            "urls": history,
            "index": index,
            // "savePath": WORKSPACES,
            "isFavourite": true,
          });
        },
        child: SDAgeLevelCover(item)
        // return file.existsSync()?InkWell(

        //   // child: AgeLevelCover(item),
        //   child:
        //   Image.file(File(item.localPath!))
        );
    //
    // ):CachedNetworkImage(imageUrl: placeHolderUrl(width:256,height:256));
  }
}
