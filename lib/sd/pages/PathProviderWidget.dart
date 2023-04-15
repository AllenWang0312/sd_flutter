import 'package:flutter/cupertino.dart';

enum StorageType { Public, Hide, Private }

enum StyleResType { reomote, copy, empty }

abstract class PathProviderWidget extends StatelessWidget {
  late String applicationPath;

  String? publicPath;
  String? openHidePath;

  PathProviderWidget(
    this.applicationPath,
  {  this.publicPath,
    this.openHidePath,}
  );

  String getStoragePath(StorageType? value, String name) {
    if (value == StorageType.Public) {
      return "$publicPath/$name";
    } else if (value == StorageType.Hide) {
      return "$openHidePath/$name";
    } else {
      return "$applicationPath/$name";
    }
  }
}
