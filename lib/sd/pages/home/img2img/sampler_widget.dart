import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean4json/Sampler.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../../../common/ui_util.dart';
import '../../../const/config.dart';
import '../../../http_service.dart';

class SDSamplerWidget extends StatelessWidget {
  // get selectedSampler {
  //   if (samplers.isEmpty) {
  //     return null;
  //   } else {
  //     return samplers[selectedSamplerPosition];
  //   }
  // }

  List<Sampler> samplers = [];
  int selectedSamplerPosition = 0;

  Future<Response?> getSamplers = get("$sdHttpService$GET_SAMPLERS");

  @override
  Widget build(BuildContext context) {
    AIPainterModel provider =
        Provider.of<AIPainterModel>(context, listen: false);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).sampler),
            FutureBuilder(
                future: getSamplers,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List re = snapshot.data?.data as List;
                    samplers = re.map((e) => Sampler.fromJson(e)).toList();
                    // samplers = ;
                    return Selector<AIPainterModel, String>(
                      selector: (context, model) => model.txt2img.sampler,
                      shouldRebuild: (pre, next) => next != pre,
                      builder: (context, sampler, child) => DropdownButton(
                          value: sampler,
                          // hint: Text(selectedUpScale != null
                          //     ? "${selectedUpScale!.name}"
                          //     : "请选择模型"),
                          items: getNamesItems(samplers),
                          onChanged: (newValue) {
                            provider.selectSampler(newValue);
                          }),
                    );
                  } else {
                    return myPlaceholder(100, 20);
                  }
                })
          ],
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context).samplerSteps),
            SizedBox(
                width: 40,
                child: Selector<AIPainterModel, int>(
                  selector: (context, model) => model.txt2img.steps,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, steps, child) {
                    TextEditingController samplerStepsController =
                        TextEditingController(text: steps.toString());

                    return TextFormField(
                        // initialValue: provider.samplerSteps.toString(),
                        controller: samplerStepsController);
                  },
                )),
            Expanded(
              child: Selector<AIPainterModel, int>(
                selector: (context, model) => model.txt2img.steps,
                shouldRebuild: (pre, next) => pre != next,
                builder: (context, steps, child) => Slider(
                  value: steps.toDouble(),
                  min: 30,
                  max: 90,
                  divisions: 6,
                  onChanged: (double value) {
                    print("steps seek$value");
                    provider.updateSteps(value);
                    // samplerStepsController.text = samplerSteps.toString();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text("厚涂"),

            Expanded(
              child: Selector<AIPainterModel, int>(
                  selector: (context, model) => model.txt2img.steps,
                  builder: (context, steps, child) {
                    return Selector<AIPainterModel, int>(
                      selector: (context, model) => model.txt2img.shapSteps,
                      shouldRebuild: (pre, next) => pre != next,
                      builder: (context, shapSteps, child) => Slider(
                        value: shapSteps.toDouble(),
                        min: 10,
                        max: steps.toDouble(),
                        divisions: (steps - 10) ~/ 5,
                        onChanged: (double value) {
                          // print("steps seek$value");
                          provider.updateShapeSteps(value);
                          // samplerStepsController.text = samplerSteps.toString();
                        },
                      ),
                    );
                  }),
            ),
            Selector<AIPainterModel, int>(
              selector: (context, model) => model.txt2img.shapSteps,
              shouldRebuild: (pre, next) => pre != next,
              builder: (context, shapSteps, child) => Text(shapSteps.toString()),
            ),
          ],
        ),
        Row(
          children: [
            Text("细节"),

            Expanded(
              child: Selector<AIPainterModel, int>(
                  selector: (context, model) => model.txt2img.steps,
                  builder: (context, steps, child) {
                    return Selector<AIPainterModel, int>(
                      selector: (context, model) => model.txt2img.detailSteps,
                      shouldRebuild: (pre, next) => pre != next,
                      builder: (context, detailSteps, child) => Slider(
                        value: detailSteps.toDouble(),
                        min: 10,
                        max: steps.toDouble(),
                        divisions: (steps - 10) ~/ 5,
                        onChanged: (double value) {
                          // print("steps seek$value");
                          provider.updateDetailSteps(value);
                          // samplerStepsController.text = samplerSteps.toString();
                        },
                      ),
                    );
                  }),
            ),
            Selector<AIPainterModel, int>(
              selector: (context, model) => model.txt2img.detailSteps,
              shouldRebuild: (pre, next) => pre != next,
              builder: (context, detailSteps, child) => Text(detailSteps.toString()),
            ),
          ],
        )
      ],
    );
  }
}
