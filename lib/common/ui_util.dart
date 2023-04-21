
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sd/common/util/file_util.dart';

import '../sd/bean/Named.dart';


List<DropdownMenuItem> getStringItems(List<String> nameds) {
  return nameds
      .map((e) => DropdownMenuItem(
    value: e,
    child: Text(e),
  ))
      .toList();
}

List<DropdownMenuItem> getMapItems(List<Named> nameds) {
  return nameds
      .map((e) => DropdownMenuItem(
    value: e,
    child: Text(e.getInterfaceName()),
  ))
      .toList();
}

List<DropdownMenuItem> getNamesItems(List<Named> nameds) {
  return nameds
      .map((e) => DropdownMenuItem(
    value: e.getInterfaceName(),
    child: Text(e.getInterfaceName()),
  ))
      .toList();
}

List<DropdownMenuItem> getFileItems(List<FileSystemEntity> nameds) {
  return nameds
      .map((e) => DropdownMenuItem(
    value: e,
    child: Text(getFileName(e.path)),
  ))
      .toList();
}
