import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/Expandable.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import 'PromptStyle.dart';

const TAG = "Optional";

class Optional extends PromptStyle {
  bool? _isRaido;

  bool get isRadio {
    _isRaido ??= name.endsWith("*");
    return _isRaido!;
  }

  Optional? parent;

  Optional(super.name,
      {super.group,
      super.step,
      super.limitAge,
      super.type,
      super.prompt,
      super.negativePrompt});

  Map<String, Optional>? options;

  void addOption(String name, Optional item) {
    options ??= {};
    item.parent = this;
    options!.putIfAbsent(item.name, () => item);
  }

  Optional createIfNotExit(List<String> names, int i) {
    logt(
      TAG,
      "createIfNotExit $names   $i",
    );
    options ??= {};
    Optional option;

    String name = names[i];
    if (options!.keys.contains(name)) {
      option = options![name]!;
    } else {
      option = Optional(name);
      addOption(name, option);
    }

    if (i != names.length - 1) {
      return option.createIfNotExit(names, i + 1);
    } else {
      return option;
    }
  }

  Widget generate(AIPainterModel provider) {
    if (null != options && options!.keys.isNotEmpty) {
      return Expandable(
          true,
          Row(
            children: [
              if(name.endsWith("*"))Checkbox(value: provider.checkedRadio.contains(name), onChanged: (newValue) {
                if (newValue != null && newValue&&null!=group) {
                  //勾选
                  provider.updateCheckRadio(group!,name);
                } else {
                  //取消
                  provider.updateCheckRadio(group!, null);
                }
              }),
              Text(name),
              IconButton(onPressed: () {}, icon: Icon(Icons.refresh))
            ],
          ),
          content(provider, options));
    } else {
      return Text(name);
    }
  }

  @override
  String toString() {
    return 'Optional{$name $group $isRadio $options}';
  }

  Widget content(AIPainterModel provider, Map<String, Optional>? options) {
    List<Optional> ops = options!.values.toList();
    // bool noChild = true;
    // for (Optional item in ops) {
    //   if (null != item.options && item.options!.isNotEmpty) {
    //     noChild = false;
    //   }
    // }
    List<List<Optional>> splits = splitOptional(ops);

    List<Widget> noChild = splits[0].map<Widget>((e) {
      if (e.isRadio) {
        return Selector<AIPainterModel, List<String>>(
            selector: (_, model) => model.checkedRadio,
            builder: (_, newValue, child) {
              return ChoiceChip(
                label: Text(e.name),
                  selected: newValue.contains(e.name),
                  onSelected: (newValue) {
                    if (newValue != null && newValue&&null!=e.group) {
                      //勾选
                      provider.updateCheckRadio(e.group!,e.name);
                    } else {
                      //取消
                      provider.updateCheckRadio(e.group!, null);
                    }
                    // provider.switchChecked(newValue ?? false, e.name);
                  });
            });
      } else {
        if (e.checked == null) {
          e.checked = provider.checkedStyles.contains(e.name);
        }
        return RawChip(
            selected: e.checked!,
            onSelected: (bool selected) {
              e.checked = !e.checked!;
              provider.switchChecked(selected, e.name);
            },
            label: Text(e.name));
      }
    }).toList();

    List<Widget> hasChild = [];
    if (noChild.isNotEmpty) {
      hasChild.add(Wrap(
        //
        children: noChild,
      ));
    }
    hasChild.addAll(splits[1].map<Widget>((value) {
      return value.generate( provider);
      //   Row(
      //   children: [
      //     Radio<String>(
      //         value: value.name,
      //         groupValue: value.parent?.target,
      //         onChanged: (newValue) {
      //           value.parent!.target = newValue;
      //           provider.replaceChecked(value.parent?.target, newValue);
      //         }),
      //     value.generate(provider),
      //   ],
      // );
    }).toList());

    return Container(
      padding: const EdgeInsets.only(left: 12),
      child: hasChild.length == 1
          ? Wrap(
              children: noChild,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: hasChild,
            ),
    );
  }

  List<List<Optional>> splitOptional(List<Optional> ops) {
    List<Optional> noChild = [];
    List<Optional> withChild = [];
    for (Optional item in ops) {
      if (null == item.options || item.options!.isEmpty) {
        noChild.add(item);
      } else {
        withChild.add(item);
      }
    }
    return [noChild, withChild];
  }
}
