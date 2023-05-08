

import 'package:flutter/material.dart';


abstract class PageListViewer extends StatefulWidget{
  // PageListViewer({super.key});

  int pageNum = 0;
  int pageSize = 36;
  bool dateOrder = true;

  void returnTopAndRefresh();

}