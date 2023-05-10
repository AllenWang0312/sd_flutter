import 'package:flutter/material.dart';

const BUSY = 3;
const REQUESTING = 2;

const ONLINE = 1;
const OFFLINE = 0;


Color getStateColor(int state){
  if(state==ONLINE){
    return Colors.green;
  }else if(state == OFFLINE){
    return Colors.red;
  }else{
    // if(netWorkState==BUSY||netWorkState==REQUESTING){
    return Colors.orange;
  }

}

mixin NetWorkStateProvider {
  int netWorkState = 0; //-1 表示上次执行报错 点击历史查看 0表示刚初始化/请求成功 1 表示正在请求
  void updateNetworkState(int state);

}
