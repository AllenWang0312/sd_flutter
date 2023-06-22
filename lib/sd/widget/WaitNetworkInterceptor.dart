import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/pages/home/home_page.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

class WaitNetworkInterceptor extends StatelessWidget {
  Widget child;

  WaitNetworkInterceptor(this.child);

  @override
  Widget build(BuildContext context) {
    return Selector<AIPainterModel, int>(
      selector: (_, model) => model.netWorkState,
      builder: (_, newValue, child) {
        return WillPopScope(
            child: this.child,
            onWillPop: () async {
              if (newValue > REQUEST_ERROR) {
                Fluttertoast.showToast(msg: "正在等待生成图片");
                return false;
              }
              return true;
            });
      },
    );
  }
}
