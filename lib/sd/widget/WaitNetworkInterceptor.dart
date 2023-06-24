import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/pages/home/home_page.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

class WaitNetworkInterceptor extends StatelessWidget {
  Widget child;

  WaitNetworkInterceptor(this.child);

  late AIPainterModel provider;
  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context,listen: false);
    return WillPopScope(
        child: this.child,
        onWillPop: () async {
          if(provider.index>0){
            provider.updateIndex(0);
            return false;
          }
          if (provider.netWorkState > REQUEST_ERROR) {
            Fluttertoast.showToast(msg: "正在等待生成图片");
            return false;
          }
          return true;
        });
  }
}
