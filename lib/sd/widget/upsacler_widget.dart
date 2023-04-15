import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/model/AIPainterModel.dart';

import '../../common/ui_util.dart';
import '../http_service.dart';
import '../bean/UpScaler.dart';
import '../config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpScalerWidget extends StatelessWidget {
  var getUpScalers = get("$sdHttpService$GET_UPSCALERS");

  @override
  Widget build(BuildContext context) {
    AIPainterModel provider =
        Provider.of<AIPainterModel>(context, listen: false);

    TextEditingController hiresStepsController =
        TextEditingController(text: provider.hiresSteps.toString());
    return Column(
      children: [
        Selector<AIPainterModel, double>(
            selector: (_, model) => model.upscale,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, newValue, child) {
              TextEditingController controller =
              TextEditingController(text: newValue.toStringAsFixed(1));
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).upscaleBy),
                  SizedBox(
                      width: 40,
                      child: TextFormField(
                        // initialValue: newValue.toString(),
                          controller: controller)),
                  Slider(
                    value: newValue,
                    min: 1.5,
                    max: 4,
                    divisions: 5,
                    onChanged: (double value) {
                      provider.updateScale(value);
                      // samplerStepsController.text = samplerSteps.toString();
                    },
                  )
                ],
              );
            }),

        Selector<AIPainterModel, int>(
            selector: (_, model) => model.scalerWidth,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, newValue, child) {
              TextEditingController widthController =
                  TextEditingController(text: newValue.toString());
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(AppLocalizations.of(context).resizeWidthTo),
                  SizedBox(
                      width: 40,
                      child: TextFormField(
                          // initialValue: newValue.toString(),
                          controller: widthController)),
                  Slider(
                    value: newValue.toDouble(),
                    min: 512,
                    max: 2560,
                    divisions: 16,
                    onChanged: (double value) {
                      provider.updateScalerWidth(value);
                      // samplerStepsController.text = samplerSteps.toString();
                    },
                  )
                ],
              );
            }),
        Selector<AIPainterModel, int>(
            selector: (_, model) => model.scalerHeight,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, newValue, child) {
              TextEditingController heightController =
                  TextEditingController(text: newValue.toString());
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).resizeHeightTo),
                  SizedBox(
                      width: 40,
                      child: TextFormField(
                        // initialValue: newValue.toString(),
                        controller: heightController,
                      )),
                  Slider(
                    value: newValue.toDouble(),
                    min: 512,
                    max: 2560,
                    divisions: 16,
                    onChanged: (double value) {
                      provider.updateScalerHeight(value);
                    },
                  )
                ],
              );
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(AppLocalizations.of(context).upscaler),
            FutureBuilder(
              future: getUpScalers,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List re = snapshot.data?.data as List;
                  provider.upScalers =
                      re.map((e) => UpScaler.fromJson(e)).toList();
                  // samplers = ;
                  return DropdownButton(
                      value: Provider.of<AIPainterModel>(context).selectedUpScale,
                      // hint: Text(selectedSampler != null
                      //     ? "${selectedSampler!.name}"
                      //     : "请选择模型"),
                      items: getNamesItems(provider.upScalers),
                      onChanged: (newValue) {
                        print(newValue);
                        // setState(() {
                        provider.updateScaleMethod(newValue);
                        // });
                      });
                } else {
                  return const Placeholder(
                    fallbackHeight: 20,
                    fallbackWidth: 100,
                  );
                }
              },
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).hiresSteps),
            SizedBox(
                width: 40,
                child: TextFormField(controller: hiresStepsController)),
            Slider(
              value: provider.hiresSteps.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              onChanged: (double value) {
                // setState(() {
                provider.updateHiresSteps(value);
                // });
              },
            ),
          ],
        ),
      ],
    );
  }
}
