import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../common/third_util.dart';
import '../http_service.dart';
import '../bean/Showable.dart';
import '../config.dart';
import '../model/AIPainterModel.dart';

class ImagesViewer<T extends Showable> extends StatelessWidget {
  final String TAG = "ImageViewer";
  int? pageSize;
  int? pageNum;
  int? index;

  late Function? loadMore;

  List<T>? urls;
  List<Uint8List>? datas;
  String? saveDirPath;

  ImagesViewer({this.urls, this.loadMore, this.datas,this.saveDirPath});

  @override
  Widget build(BuildContext context) {
    AIPainterModel provider = Provider.of<AIPainterModel>(context);
    PageController controller = PageController();
    controller.addListener(() {
      // logd(controller.page.toString());
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: urls != null && urls!.length > 0
                  ? PageView.builder(
                      onPageChanged: (page) async {
                        // if(null!=loadMore&&page>datas!.length/3*2){
                        // datas?.addAll(await loadMore(pageNum,pageSize));
                        // }
                        logt(TAG,page.toString());
                      },
                      controller: controller,
                      itemCount: urls!.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                            imageUrl: (urls![index].getUrl()));
                      })
                  // : filePath != null
                  // ? Image.file(File(filePath!))
                  // : bytes != null
                  // ? Image.memory(bytes!)
                  : PageView.builder(
                      onPageChanged: (page) async {
                        // if(null!=loadMore&&page>datas!.length/3*2){
                        // datas?.addAll(await loadMore(pageNum,pageSize));
                        // }
                        logt(TAG,page.toString());
                      },
                      controller: controller,
                      itemCount: urls!.length,
                      itemBuilder: (context, index) {
                        return Image.memory(datas![index]);
                      }),
            ),
          ),
          InkWell(
              onTap: () async {
                if (await checkStoragePermission()) {
                  logt(TAG,controller.page!.toInt().toString());
                  dynamic result = await saveUrlToLocal(
                      context,
                      urls![controller.page!.toInt()].getUrl(),
                      "${DateTime.now()}.png",saveDirPath??provider.selectWorkspace!.dirPath);
                  Fluttertoast.showToast(msg: result.toString());
                } else {
                  Fluttertoast.showToast(msg: "请允许应用使用存储权限");
                }
              },
              child: Container(
                  height: 48,
                  color: COLOR_ACCENT,
                  child: const Text(
                    "save to file",
                    style: TextStyle(color: Colors.white),
                  ))),
        ],
      ),
    );
  }
}
