const REQUESTING = 1;
const INIT = 0;
const ERROR = -1;

abstract class NetWorkStateProvider {
  int isGenerating = 0; //-1 表示上次执行报错 点击历史查看 0表示刚初始化/请求成功 1 表示正在请求

  void updateNetworkState(int state);
}