
import 'package:flutter/material.dart';

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
