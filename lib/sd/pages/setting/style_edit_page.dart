import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/http_service.dart';

import '../../bean4json/PostPredictResult.dart';
import '../../mocker.dart';

class SDStyleEditPage extends StatelessWidget {
  String? title;

  String? styleName;
  String? prompt;
  String? negPrompt;

  SDStyleEditPage(int cmd,{this.title,this.styleName,this.prompt,this.negPrompt});


  @override
  Widget build(BuildContext context) {
    var nameController = TextEditingController(text: styleName);
    var promptController = TextEditingController(text: prompt);
    var negPromptController = TextEditingController(text: negPrompt);
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : Text("新建style"),
        actions: [
          TextButton(
              onPressed: () {
                post("$sdHttpService$RUN_PREDICT", formData: {
                  "data": [
                    nameController.text,
                    promptController.text,
                    negPromptController.text
                  ],
                  "fn_index": cmd
                }, exceptionCallback: (e) {
                  Fluttertoast.showToast(msg: "保存失败",gravity: ToastGravity.CENTER);
                }).then((value) {
                  var result = RunPredictResult.fromJson(value?.data);
                  if (result.duration > 0) {
                    Navigator.pop(context, 1);
                    Fluttertoast.showToast(msg: '保存成功',gravity: ToastGravity.CENTER);
                  }
                });
              },
              child: Text('保存'))
        ],
      ),
      body: Column(
        children: [
          Text("名称"),
          TextField(
            controller: nameController,
          ),
          Text("prompt"),
          TextField(
            controller: promptController,
          ),
          Text("negative prompt"),
          TextField(
            controller: negPromptController,
          ),
        ],
      ),
    );
  }
}
