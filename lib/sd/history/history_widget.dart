import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/bean/db/History.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/db_controler.dart';
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
    state._scroller.jumpTo(0);

    if(pageNum>0){
      pageNum=0;
      state.loadData(pageNum, pageSize, dateOrder, asc);
    }

    // state._controller.callRefresh()
  }
}

class _HistoryWidgetState extends State<HistoryWidget> with AutomaticKeepAliveClientMixin{

  List<History> history = [];

  int viewType = 0;

  //list grid flot scale


  late EasyRefreshController _controller;
  late ScrollController _scroller;

  @override
  Widget build(BuildContext context) {
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _scroller = ScrollController();
    return EasyRefresh.builder(
        refreshOnStart: true,
        controller: _controller,
        onRefresh: () async {
          widget.pageNum = 0;
          history.clear();
          loadData(widget.pageNum, widget.pageSize, widget.dateOrder, widget.asc);
        },
        onLoad: () async {
          widget.pageNum += 1;
          loadData(widget.pageNum, widget.pageSize, widget.dateOrder, widget.asc);
        },
        childBuilder: (context, physics) {
          return MasonryGridView.count(
            physics: physics,
            controller: _scroller,
            itemCount: history.length,
            itemBuilder: (context, index) {
              // History item = History.fromJson(snapshot.data![index]);
              History item = history[index];
              // Uri uri = Uri.file(item.localPath!);
              // File(uri.ab);

              File file = File(item.localPath!);
              AIPainterModel provider = Provider.of<AIPainterModel>(context);
              return file.existsSync()?InkWell(
                onTap: () async {
                  Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER,
                      arguments: {
                        "urls": history,
                        "index": index,
                        // "savePath": WORKSPACES,
                        "scanAvailable":provider.sdServiceAvailable,
                        "isFavourite":true,
                      });
                },
                // child: AgeLevelCover(item),
                child: Image.file(file),

              ):CachedNetworkImage(imageUrl: placeHolderUrl(width:256,height:256));
            },
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          );
        });
  }

  loadData(int pageNum, int pageSize, bool dateOrder, bool asc,
      {bool filterNotExist = false}) {
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
      // logt(TAG,list.toString());
      if (filterNotExist) {
        list.removeWhere((element) =>
        element.localPath == null || !File(element.localPath!).existsSync());
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
        _controller.finishRefresh(IndicatorResult.fail);
        _controller.finishLoad(IndicatorResult.noMore);
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
