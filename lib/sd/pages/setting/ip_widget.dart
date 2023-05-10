

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/config.dart';
import '../../http_service.dart';

class IpWidget extends StatefulWidget {
  Future<SharedPreferences> prefs;

  IpWidget(this.prefs, {super.key});

  @override
  _IpWidgetState createState() => _IpWidgetState();
}
class _IpWidgetState extends State<IpWidget>{

  TextEditingController ipController =
  TextEditingController(text: sdHost);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 100,
          child: TextFormField(
            controller: ipController,
          ),
        ),
        Text(SD_PORT.toString()),
        ElevatedButton(
          child: Text("save"),
          onPressed: () {
            var spHost = widget.prefs.then((value) => value.getString(KEY_HOST));
            if (spHost != ipController.text) {
              setState(() {
                sdHost = ipController.text;
              });
              widget.prefs.then((value) async {
                var suc =
                await value.setString(KEY_HOST, ipController.text);
                if (suc) {
                  print("save host success $sdHost");
                  Fluttertoast.showToast(msg: '保存成功',gravity: ToastGravity.CENTER);
                  // initConfig();
                }
              });
            } else {
              Fluttertoast.showToast(msg: '无需重复保存',gravity: ToastGravity.CENTER);
            }
          },
        )
      ]),
    );
  }
}
