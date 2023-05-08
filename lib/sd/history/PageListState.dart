
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:sd/sd/widget/PageListViewer.dart';

abstract class PageListState<T extends PageListViewer> extends State<T>{

  late EasyRefreshController controller;
  late ScrollController scroller;

}