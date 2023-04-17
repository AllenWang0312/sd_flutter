import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../common/third_util.dart';
import '../bean/Showable.dart';
import '../http_service.dart';
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

  ImagesViewer(
      {this.urls, this.index, this.loadMore, this.datas, this.saveDirPath});

  @override
  Widget build(BuildContext context) {
    // AIPainterModel provider = Provider.of<AIPainterModel>(context);
    PageController controller = PageController(initialPage: 2);

    controller.addListener(() {});
    var content = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: urls != null && urls!.isNotEmpty
                  ? PageView.builder(
                      onPageChanged: (page) async {
                        logt(TAG, page.toString());
                      },
                      controller: controller,
                      itemCount: urls!.length,
                      itemBuilder: (context, index) {
                        T data = urls![index];
                        return data.getUrl().startsWith("http")
                            ? CachedNetworkImage(imageUrl: (data.getUrl()))
                            : Image.file(File(data.getUrl()));
                      })
                  : PageView.builder(

                      onPageChanged: (page) async {
                        logt(TAG, page.toString());
                      },
                      controller: controller,
                      itemCount: datas!.length,
                      itemBuilder: (context, index) {
                        return Image.memory(datas![index]);
                      }),
            ),
          ),
          Offstage(
            offstage: saveDirPath == null,
            child: TextButton(
              onPressed: () async {
                if (await checkStoragePermission()) {
                  logt(TAG, controller.page!.toInt().toString());
                  dynamic result = await saveUrlToLocal(
                      urls![controller.page!.toInt()].getUrl(),
                      "${DateTime.now()}.png", saveDirPath!);
                  Fluttertoast.showToast(msg: result.toString());
                } else {
                  Fluttertoast.showToast(msg: "请允许应用使用存储权限");
                }
              },
              child: const Text("save to file"),
            ),
          )
        ],
      ),
    );
    return content;
  }
}
