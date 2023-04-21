import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/mocker.dart';
import 'package:sd/sd/AIPainterModel.dart';

import '../bean/Configs.dart';
import '../config.dart';
import '../roll/tagger_widget.dart';
import '../http_service.dart';


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
        Text(AppLocalizations
            .of(context)
            .prompt + ":"),
        Row(
          children: [
            Expanded(
              child: Selector<AIPainterModel, String>(
                selector: (_, model) => model.config.prompt,
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
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Text(AppLocalizations
                                  .of(context)
                                  .tagger),
                              content: ChangeNotifierProvider(
                                create: (_) => TaggerModel(),
                                child: TaggerWidget(),
                              ),
                            );
                          });
                    },
                    icon: Icon(Icons.image_search)),
                IconButton(
                    onPressed: () {
                      var prompt = promptController.text;
                      Configs dec = Configs.fromString(prompt);
                      // provider.updatePrompt(dec.prompt);
                      provider.updateConfigs(dec);
                    },
                    icon: Transform.rotate(
                      angle: -pi / 4,
                      child: Icon(Icons.arrow_back),
                    ))
              ],
            )
          ],
        ),
        Text(AppLocalizations
            .of(context)
            .negativePrompt + ":"),
        Row(
          children: [
            Expanded(
              child: Selector<AIPainterModel, String>(
                  selector: (_, model) => model.config.negativePrompt,
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
                    child: Text(AppLocalizations
                        .of(context)
                        .clean)),
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
                    child: Text(AppLocalizations
                        .of(context)
                        .load)),
                TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(
                            context, ROUTE_STYLE_EDITTING,
                            arguments: {
                              "title": "新建style",
                              "prompt": promptController.text,
                              "negPrompt": negController.text
                            }),
                    child: Text(AppLocalizations
                        .of(context)
                        .save)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
