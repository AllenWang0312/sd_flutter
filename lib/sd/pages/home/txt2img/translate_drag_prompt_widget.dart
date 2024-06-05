import 'package:flutter/material.dart';
import 'package:sd/common/util/string_util.dart';

import '../../../bean/db/Translate.dart';
import 'drag_prompt_widget.dart';

class SDTranslateDragPromptWidget extends StatelessWidget {
  // late List<dynamic> split;
  // List<String>? translate;
  // List<int>? colors;

  String? title = '';
  String? prompt = '';
  late List<Translate> split;

  SDTranslateDragPromptWidget(this.title, this.prompt, {super.key}) {
    if (null != prompt) {
      split = [];
      List prompts = prompt!.split(',');
      for (String item in prompts) {
        // if (item.length > 30&&item.contains(' ')) {
        split.add(Translate(keyWords: item));
        // } else {
        //   split.add(item.trim());
        // }
      }
    }
  }

  late TextEditingController editting;
  late SDDragPromptWidget dragPromptWidget;

  @override
  Widget build(BuildContext context) {
    editting = TextEditingController(text: "");
    editting.addListener(() {
      String text = editting.text;
      if(allChinease(text)){

      }
    });


    dragPromptWidget = SDDragPromptWidget(split);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          dragPromptWidget,
          Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          strutStyle: StrutStyle.disabled,
                          controller: editting,
                        ),
                      ),
                      GestureDetector(
                          onTapDown: (details) {
                            dragPromptWidget.showTrans(true);
                          },
                          onTapUp: (details) {
                            dragPromptWidget.showTrans(true);
                          },
                          child: Icon(Icons.translate))
                    ],
                  )
                ],
              ))
        ],
      ),
    );
  }
}
