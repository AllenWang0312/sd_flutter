// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import 'package:sd/sd/config.dart';
// import 'package:sd/sd/model/AIPainterModel.dart';
//
// import '../../common/third_util.dart';
//
// class ImageViewer extends StatelessWidget {
//   String? url;
//   String? filePath;
//   Uint8List? bytes;
//   String? savePath;
//
//   ImageViewer({this.url, this.filePath, this.bytes,this.savePath});
//
//   @override
//   Widget build(BuildContext context) {
//     AIPainterModel provider = Provider.of<AIPainterModel>(context);
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: url != null
//                   ? CachedNetworkImage(
//                       imageUrl: (url!))
//                   : filePath != null
//                       ? Image.file(File(filePath!))
//                       : bytes != null
//                           ? Image.memory(bytes!)
//                           : Text("没有找到数据"),
//             ),
//           ),
//           Offstage(
//             offstage: savePath == null,
//             child: InkWell(
//                 onTap: () async {
//                   if (await checkStoragePermission()) {
//                     if (url != null) {
//                       saveUrlToLocal(url!, "${DateTime.now()}.png",
//                           savePath!);
//                     } else {
//                       saveBytesToLocal(bytes, "${DateTime.now()}.png",
//                           savePath!);
//                     }
//                   } else {
//                     Fluttertoast.showToast(msg: "请允许应用使用存储权限");
//                   }
//                 },
//                 child: Container(
//                     height: 48,
//                     color: COLOR_ACCENT,
//                     child: const Text(
//                       "save to file",
//                       style: TextStyle(color: Colors.white),
//                     ))),
//           ),
//         ],
//       ),
//     );
//   }
// }
