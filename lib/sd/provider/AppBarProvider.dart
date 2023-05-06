import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

List<Widget> remapActionsToWidget(Map<dynamic, Function()> actions) {
  return actions.keys.map((e) {
    if (e is IconData) {
      return IconButton(onPressed: actions![e], icon: Icon(e));
    } else if (e is Widget) {
      return InkWell(
        onTap: actions![e],
        child: e,
      );
    }
    return Container();
  }).toList();
}

class AppBarProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String? title;

  Map<dynamic, Function()>? actions;

  IconData? leading;
  Function()? leadingCallback;

  void updateTitle(String? title, {bool notify = true}) {
    this.title = title;
    if (notify) notifyListeners();
  }

  void updateLeadingIcon(IconData? icon, Function() callback,
      {bool notify = true}) {
    this.leading = icon;
    this.leadingCallback = callback;
    if (notify) notifyListeners();
  }

  void updateActions(Map<dynamic, Function()> actions, {bool notify = true}) {
    this.actions = actions;
    if (notify) notifyListeners();
  }

  void addActions(Map<dynamic, Function()> actions, {bool notify = true}) {
    if (null == this.actions) {
      actions = {};
    }
    actions.keys.forEach((element) {
      if (null != this.actions && this.actions!.keys.contains(element)) {
        this.actions!.update(element, (value) => () => actions[element]);
      } else {
        this.actions!.putIfAbsent(element, () => () => actions[element]);
      }
    });

    if (notify) notifyListeners();
  }
}
