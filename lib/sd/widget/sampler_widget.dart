import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean/Sampler.dart';
import 'package:sd/sd/model/AIPainterModel.dart';

import '../http_service.dart';
import '../config.dart';
import '../../common/ui_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SamplerWidget extends StatelessWidget {

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
    AIPainterModel provider = Provider.of<AIPainterModel>(context);
    TextEditingController samplerStepsController = TextEditingController(text: provider.samplerSteps.toString());

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).sampler),
            Text(AppLocalizations.of(context).samplerSteps),
            SizedBox(
                width: 40,
                child: Selector<AIPainterModel, int>(
                  selector: (context, model) => model.samplerSteps,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, steps, child) => TextFormField(
                      // initialValue: provider.samplerSteps.toString(),
                      controller: samplerStepsController),
                ))
          ],
        ),
        Row(
          children: [
            FutureBuilder(
                future: getSamplers,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List re = snapshot.data?.data as List;
                    samplers = re.map((e) => Sampler.fromJson(e)).toList();
                    // samplers = ;
                    return Selector<AIPainterModel, String>(
                      selector: (context, model) => model.selectedSampler,
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
                    return const Placeholder(
                      fallbackHeight: 20,
                      fallbackWidth: 100,
                    );
                  }
                }),
            Expanded(
              child: Selector<AIPainterModel, int>(
                selector: (context, model) => model.samplerSteps,
                shouldRebuild: (pre, next) => pre != next,
                builder: (context, steps, child) => Slider(
                  value: provider.samplerSteps.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  onChanged: (double value) {
                    print("steps seek$value");
                    provider.updateSteps(value);
                    // samplerStepsController.text = samplerSteps.toString();
                  },
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
