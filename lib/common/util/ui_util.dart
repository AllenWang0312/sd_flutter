

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/widget/restartable_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const SHAPE_IMAGE_CARD = RoundedRectangleBorder(
    borderRadius:
    BorderRadius.all(Radius.circular(12.0)));


var AGE_LEVEL_BLUR = ImageFilter.blur(
  sigmaX: 12,
  sigmaY: 12,
);

var CHECK_IDENTITY = ImageFilter.blur(sigmaX: 15, sigmaY: 15);

bottomSheetItem(String title, Function()? callback) {
  return SizedBox(
    height:48,
    child: InkWell(
      onTap: callback,
      child: Center(
        child: Text(title),
      ),
    ),
  );
}


void showRestartDialog(BuildContext context){
    showDialog(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: Text(AppLocalizations.of(context).restartDialogTitle),
                content: Text(AppLocalizations.of(context).restartDialogContent),
                actions: [
                    TextButton(
                        onPressed: () async {
                          sdShare = null;
                          sdPublicDomain = null;
                          sdHttpService = null;
                            RestartableWidget.restartApp(context);
                        },
                        child: Text(AppLocalizations.of(context).ok))
                ],
            );
        });
}

void showRestartNowDialog(BuildContext context){
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).restartDialogTitle),
          content: Text(AppLocalizations.of(context).restartNowContent),
          actions: [
            TextButton(
                onPressed: () async {
                  RestartableWidget.restartApp(context);
                },
                child: Text(AppLocalizations.of(context).ok))
          ],
        );
      });
}