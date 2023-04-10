import 'package:flutter/cupertino.dart';

class EmptyView extends StatelessWidget {
  bool? error = false;


  EmptyView({this.error});

  // EmptyView.error(){
  //   return EmptyView(true);
  // }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          children: [
      // Image.asset(Named)
      Text(error==true?"发生了一些错误":"暂无数据")
      ],
    ),);
  }
}