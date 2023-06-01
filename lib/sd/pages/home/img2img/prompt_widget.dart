import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/const/routes.dart';
import 'package:sd/sd/mocker.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../../bean/Configs.dart';
import '../../../const/config.dart';
import '../../../http_service.dart';
import '../txt2img/tagger_widget.dart';

class PromptWidget extends StatelessWidget {
  static const String TAG = "PromptWidget";

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
        Text("${AppLocalizations.of(context).prompt}:"),
        Row(
          children: [
            Expanded(
              child: Selector<AIPainterModel, String>(
                selector: (_, model) => model.txt2img.prompt,
                builder: (context, newValue, child) {
                  promptController = TextEditingController(text: newValue);
                  return TextFormField(
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
            Column(
              children: [

                TextButton(
                    onPressed: () {
                      post("$sdHttpService$RUN_PREDICT",
                          formData: getLastPrompt(cmd.CMD_GET_LAST_PROMPT),
                          provider: provider, exceptionCallback: (e) {
                            logt(TAG, e.toString());
                          }).then((value) {
                        // promptController.text = value?.data['data'][0]['value'];
                        // provider.cleanCheckedStyles();
                        if (value != null) {
                          provider.cleanCheckedStyles(notify: false);
                          provider.updatePrompts(
                            value.data['data'][0]['value'],
                            value.data['data'][1]['value'],
                            steps: value.data['data'][2]['value'],
                            sampler: value.data['data'][3]['value'],
                            cfgScale: value.data['data'][5]['value'],
                            seed: value.data['data'][6]['value'],
                          );
                        } else {}
                      });
                    },
                    child: Text(AppLocalizations.of(context).load)),
                IconButton(
                    onPressed: () {
                      var prompt = promptController.text;
                      Configs dec = provider.txt2img.updateConfigs(prompt);
                      // provider.updatePrompt(dec.prompt);
                      provider.updateConfigs(dec);
                    },
                    icon: Transform.rotate(
                      angle: -pi / 4,
                      child: Icon(Icons.arrow_back),
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context,
                          // ROUTE_DRAG_PROMPT,
                          ROUTE_AUTO_COMPLETE,
                          arguments: {"prompt": promptController.text});
                    },
                    icon: Icon(Icons.auto_awesome))
              ],
            )
          ],
        ),
        Text(AppLocalizations.of(context).negativePrompt + ":"),
        Row(
          children: [
            Expanded(
              child: Selector<AIPainterModel, String>(
                  selector: (_, model) => model.txt2img.negativePrompt,
                  builder: (context, newValue, child) {
                    negController = TextEditingController(text: newValue);
                    return TextField(
                      // textInputAction: TextInputAction.send,
                      maxLines: 4,
                      controller: negController,
                      onEditingComplete: () {
                        provider.updateNegPrompt(negController.text);
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
                    child: Text(AppLocalizations.of(context).clean)),
                TextButton(
                    onPressed: () => Navigator.pushNamed(
                            context, ROUTE_STYLE_EDITTING,
                            arguments: {
                              "cmd": cmd.saveStyle,
                              "title": "新建style",
                              "prompt": promptController.text,
                              "negPrompt": negController.text
                            }),
                    child: Text(AppLocalizations.of(context).save)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
