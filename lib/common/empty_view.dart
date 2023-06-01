import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  bool? error = false;

  EmptyView({this.error});

  // EmptyView.error(){
  //   return EmptyView(true);
  // }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline),
            Text(error == true ? "发生了一些错误" : "暂无数据")
          ],
        ),
      ),
    );
  }
}
