import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/const/routes.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/bean/db/History.dart';
import 'package:sd/sd/widget/PageListViewer.dart';

import '../../common/util/ui_util.dart';
import '../const/config.dart';
import '../http_service.dart';

const String TAG = "RemoteHistoryWidget";

class RemoteHistoryWidget extends PageListViewer {
  final String dir;
  final int fnIndex; //remote +3 fav-10 del -12
  bool? isFavourite;
  String type;

  RemoteHistoryWidget(this.dir, this.fnIndex, this.type,
      {this.isFavourite = false});

  _RemoteHistoryWidgetState state = _RemoteHistoryWidgetState();

  @override
  State<RemoteHistoryWidget> createState() => state;

  @override
  void returnTopAndRefresh() {
    state._scroller.jumpTo(0);
    if (pageNum > 0) {
      pageNum = 0;
      state.loadData(pageNum, pageSize, dateOrder);
    }
  }
}

class _RemoteHistoryWidgetState extends State<RemoteHistoryWidget>
    with AutomaticKeepAliveClientMixin {
  List<History> history = [];
  int viewType = 0;

  //list grid flot scale
  late EasyRefreshController _controller;
  late ScrollController _scroller;

  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);

    _controller = EasyRefreshController(
        controlFinishRefresh: true, controlFinishLoad: true);
    _scroller = ScrollController();

    return Stack(children: [
      EasyRefresh.builder(
          refreshOnStart: true,
          controller: _controller,
          onRefresh: refresh,
          onLoad: () async {
            if (history.length % 36 == 0) {
              widget.pageNum += 1;
              return loadData(
                  widget.pageNum, widget.pageSize, widget.dateOrder);
            }
          },
          childBuilder: (context, physics) {
            return MasonryGridView.count(
              controller: _scroller,
              physics: physics,
              itemCount: history.length,
              itemBuilder: (context, index) {
                // History item = History.fromJson(snapshot.data![index]);
                History item = history[index];
                return item.url != null
                    ? GestureDetector(
                        // onLongPress: () async {
                        //
                        // },
                        onTap: () async {
                          Object? result = await Navigator.pushNamed(
                              context, ROUTE_IMAGES_VIEWER,
                              arguments: {
                                "urls": history,
                                'fnIndex': widget.fnIndex,
                                "index": index,
                                "savePath": getWorkspacesPath(),
                                "isFavourite": widget.isFavourite,
                                "scanAvailable": provider.netWorkState>=ONLINE,
                                "type": widget.type,
                              });
                          if (result is int) {
                            //   _scroller.animateTo(newIndex.toDouble(),
                            //       duration: Duration(microseconds: 300),
                            //       curve: Curves.ease);
                          } else if (result is List<String>) {
                            _scroller.jumpTo(0);
                            await refresh();
                            // setState(() {
                            //   history.removeWhere((element) => result.contains(element.getFileLocation()));
                            // });
                          }
                        },
                        child: Hero(
                          tag: item.url!,
                          child: Selector<AIPainterModel, int>(
                            selector: (_, model) => provider.hideNSFW
                                ? model.limitedUrl(item.url!)
                                : 0,
                            builder: (context, value, child) {
                              return value >= 18
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
                          ),
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
          icon: widget.dateOrder
              ? const Icon(Icons.date_range_sharp)
              : const Icon(Icons.fiber_smart_record),
          onPressed: () {
            setState(() async {
              widget.dateOrder = !widget.dateOrder;
              widget.pageNum = 0;
              await loadData(widget.pageNum, widget.pageSize, widget.dateOrder);
            });
          }),
    ]);
  }

  Future<void> loadData(int pageNum, int pageSize, bool dateOrder) async {
    if (pageNum == 0) {
      history.clear();
    }
    await post("$sdHttpService$RUN_PREDICT", formData: {
      "data": [
        // "F:\\sd outputs\\txt2img-images",
        widget.dir,
        pageNum + 1,
        null,
        "",
        dateOrder ? "date" : "path_name"
      ], //data path_name
      "fn_index": widget.fnIndex,
    }, exceptionCallback: (e) {
      if (pageNum == 0) {
        _controller.finishLoad(IndicatorResult.fail);
      } else {
        _controller.finishLoad(IndicatorResult.fail);
      }
    }).then((value) {
      logt(TAG, value!.data.toString());
      List datas = value.data['data'];
      if(null!=datas&&datas.length>=3){
        List items = datas[2] as List;
        List<History> newList = items
            .map((e) =>
            mapToHistory(widget.dir, 1, items.indexOf(e) + 1, e['name']))
            .toList();
        // List<History> newList2 =
        //     newList.where((element) => !history.contains(element)).toList();
        if (newList.isNotEmpty) {
          setState(() {
            history.addAll(newList);
            _controller.finishRefresh(IndicatorResult.success);
            _controller.finishLoad(newList.length == 36
                ? IndicatorResult.success
                : IndicatorResult.noMore);
          });
        }
      }

    });
  }

  @override
  bool get wantKeepAlive => true;

  FutureOr refresh() {
    history.clear();
    widget.pageNum = 0;
    return loadData(widget.pageNum, widget.pageSize, widget.dateOrder);
  }
}
