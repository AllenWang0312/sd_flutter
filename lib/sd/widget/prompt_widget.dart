import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/mocker.dart';
import 'package:sd/sd/model/AIPainterModel.dart';

import '../http_service.dart';
import '../config.dart';
import '../fragment/tagger_widget.dart';

class PromptWidget extends StatelessWidget {
  PromptWidget();

  late AIPainterModel provider;
  late TextEditingController promptController;
  late TextEditingController negController;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("    prompt:"),
        Row(
          children: [
            Expanded(
              child: Selector<AIPainterModel, String>(
                selector: (_, model) => model.prompt,
                builder: (context, newValue, child) {
                  promptController = TextEditingController(text: newValue);
                  return TextField(
                    // initialValue: newValue,
                    // focusNode: FocusNode(
                    //   onKey: (_,keyEvent){
                    //     if(keyEvent.isAltPressed){
                    //
                    //     }
                    //     return KeyEventResult.handled;
                    //   }
                    // ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    controller: promptController,
                    // textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      provider.updatePrompt(promptController.text);
                    },
                  );
                },
              ),
            ),
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text("内容识别"),
                          content: ChangeNotifierProvider(
                            create: (_) => TaggerModel(),
                            child: TaggerWidget(),
                          ),
                        );
                      });
                },
                icon: Icon(Icons.image_search))
          ],
        ),
        Text("    negative prompt:"),
        Row(
          children: [
            Expanded(
              child: Selector<AIPainterModel, String>(
                  selector: (_, model) => model.negPrompt,
                  builder: (context, newValue, child) {
                    negController = TextEditingController(text: newValue);
                    return TextField(
                      // textInputAction: TextInputAction.send,
                      maxLines: 4,
                      controller: negController,
                      onEditingComplete: () {
                        provider.updatePrompt(promptController.text);
                      },
                    );
                  }),
            ),
            Column(
              children: [
                TextButton(
                    onPressed: () {
                      provider.cleanPrompts();
                    },
                    child: Text("清空")),
                TextButton(
                    onPressed: () {
                      post("$sdHttpService$RUN_PREDICT",
                              formData: getLastPrompt())
                          .then((value) {
                        // promptController.text = value?.data['data'][0]['value'];
                        // provider.cleanCheckedStyles();
                        provider.updatePrompts(value?.data['data'][0]['value'],
                            value?.data['data'][1]['value']);
                      });
                    },
                    child: Text("加载")),
                TextButton(
                    onPressed: () => Navigator.pushNamed(
                            context, ROUTE_STYLE_EDITTING,
                            arguments: {
                              "title": "新建style",
                              "prompt": promptController.text,
                              "negPrompt": negController.text
                            }),
                    child: Text("保存")),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
