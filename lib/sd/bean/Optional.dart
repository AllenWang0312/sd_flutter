import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/Expandable.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import 'PromptStyle.dart';

const TAG = "Optional";

bool autoSingle(String element) {
  return element.endsWith("*");
}

bool isSingle(String element) {
  return element.endsWith("*") || element.endsWith("^");
}

class Optional extends PromptStyle {
  bool? _isRaido;

  bool get isRadio {
    _isRaido ??= name.endsWith("*") || name.endsWith("^");
    return _isRaido!;
  }

  Optional? parent;

  Optional(super.name,
      {super.group,
      super.step,
      super.limitAge,
      super.type,
      super.prompt,
      super.repet,
      super.negativePrompt,
      super.weight}) {
    currentRepet = repet;
  }

  late int currentRepet;
  HashMap<String, Optional>? options;
  bool? _expand;

  void addOption(String name, Optional item) {
    options ??= HashMap();
    item.parent = this;
    options!.putIfAbsent(item.name, () => item);
    if ((name.isNotEmpty || group.isNotEmpty) && item.group.isEmpty) {
      item.group = groupName(group, name);
    }
    if (this.step == null && item.step != null) {
      step = item.step;
    }
  }

  Optional createIfNotExit(List<String> names, int i) {
    options ??= HashMap();
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

  Widget generate(AIPainterModel provider, int deep) {
    if (null != options && options!.keys.isNotEmpty) {
      // initExpand(provider);
      if (deep == 0) {
        return content(provider, options, deep);
      } else {
        return Expandable(
            // _expand!
            true,
            Row(
              children: [
                (isRadio ||
                        (null != prompt && prompt!.isNotEmpty) ||
                        (null != negativePrompt && negativePrompt!.isNotEmpty))
                    ? Selector<AIPainterModel, List<String>>(
                        selector: (_, model) =>
                            isRadio ? model.checkedRadio : model.checkedStyles,
                        builder: (_, newValue, child) {
                          return ChoiceChip(
                              avatar:
                                  (provider.selectorLocked("$group|$name") ||
                                          provider.lockedStyles.contains(name))
                                      ? CircleAvatar(
                                          radius: 6,
                                          child: Container(
                                            color: Colors.red,
                                          ),
                                        )
                                      : null,
                              selectedColor: Colors.grey,
                              label: Text(name),
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              selected: newValue.contains(name),
                              onSelected: (newValue) {
                                if (isRadio) {
                                  if (newValue) {
                                    //勾选
                                    provider.updateCheckRadio(group, name);
                                  } else {
                                    //取消
                                    provider.updateCheckRadio(group, null);
                                  }
                                } else {
                                  provider.switchChecked(newValue, name);
                                }
                              });
                        })
                    : Text(name),
                IconButton(
                    onPressed: () {
                      randomChild(provider);
                    },
                    icon: Icon(Icons.refresh))
              ],
            ),
            content(provider, options, deep));
      }
    } else {
      return Text(name);
    }
  }

  void randomChild(AIPainterModel provider) {
    if (
        // step != 0 && //todo 过滤还有缺陷
        null != options) {
      Iterable<Optional> all = options!.values;
      List<Optional> others = all
          .where((element) =>
              !isSingle(element.name) &&
              !provider.lockedStyles.contains(element.name) &&
              (element.prompt != null || element.negativePrompt != null))
          .toList();
      final Random random = Random();

      //本层没被锁
      if (!provider.lockedRadioGroup.contains(groupName(group, name))) {
        bool radioChecked =
            provider.checkedRadioGroup.contains(groupName(group, name));

        if (radioChecked) {
          String checkedName = provider.checkedRadio[
              provider.checkedRadioGroup.indexOf(groupName(group, name))];
          logt(TAG, "random Child $group $checkedName $step");

          Optional? checkedItem = options![checkedName];
          checkedItem!.currentRepet -= 1;
          if (checkedItem.currentRepet > 0) {
          } else {
            checkedItem.currentRepet = checkedItem.repet;
            logt(TAG,
                "random exit radio $group $checkedName ${checkedItem.currentRepet}");

            List<Optional> radios =
                all.where((element) => autoSingle(element.name)).toList();
            logt(TAG, "random radios ${radios.toString()}");

            if (radios.isNotEmpty) {
              int weights = weightCount(radios);
              int weightIndex = random.nextInt(weights);
              logt(TAG, "random radio $weightIndex");
              int index = offsetIndex(radios, weights, weightIndex);
              provider.updateCheckRadio(
                  groupName(group, name), radios[index].name);
            }
          }
        }
      }

      int checkCount = 0;
      for (Optional item in others) {
        if (provider.checkedStyles.contains(item.name)) {
          provider.removeCheckedStyles(item.name);
          logt(TAG, "random remove items$item");
          checkCount++;
        }
      }
      if (checkCount > 0 && checkCount != others.length) {
        for (int i = 0; i < checkCount; i++) {
          int ran = random.nextInt(others.length);
          logt(TAG, "random items$ran");
          provider.addCheckedStyles(others[ran].name, refresh: true);
          others.removeAt(ran);
        }
      }
    }
    if (null != options) {
      for (Optional item in options!.values) {
        item.randomChild(provider);
      }
    }
  }

  @override
  String toString() {
    return 'Optional{$name $group $isRadio $options}';
  }

  Widget content(
      AIPainterModel provider, Map<String, Optional>? options, int deep) {
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
                  selectedColor: Colors.grey,
                  label: Text(e.name),
                  selected: newValue.contains(e.name),
                  onSelected: (newValue) {
                    logt(
                        TAG, "radio onSelected ${e.group} ${e.name} $newValue");
                    if (newValue != null && newValue) {
                      //勾选
                      provider.updateCheckRadio(e.group, e.name);
                    } else {
                      //取消
                      provider.updateCheckRadio(e.group, null);
                    }
                    // provider.switchChecked(newValue ?? false, e.name);
                  });
            });
      } else {
        return Selector<AIPainterModel, List<String>>(
            selector: (_, model) => model.checkedStyles,
            builder: (_, newValue, child) {
              return ChoiceChip(
                  disabledColor: Colors.red,
                  selectedColor: Colors.grey,
                  selected: newValue.contains(e.name),
                  onSelected: (bool selected) {
                    logt(
                      TAG,
                      "onSelected $selected ${e.name}",
                    );
                    provider.switchChecked(selected, e.name);
                  },
                  label: Text(e.name));
            });
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
      return value.generate(provider, deep + 1);
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

  String groupName(String group, String name) {
    return (group.isEmpty ? "" : "$group|") + this.name;
  }

  exist(List<String> checkedStyles, Iterable<String> keys) {
    if (checkedStyles.isNotEmpty && keys.isNotEmpty) {
      for (String item in keys) {
        if (checkedStyles.contains(item)) {
          return true;
        }
      }
    }
    return false;
  }

  bool initExpand(AIPainterModel provider) {
    _expand ??= needExpands(provider, options ?? {}) ||
        name.isEmpty ||
        (provider.checkedRadioGroup.contains(group) ||
            exist(provider.checkedStyles, options?.keys ?? []));
    return _expand!;
  }

  bool needExpands(AIPainterModel provider, Map<String, Optional> options) {
    for (String entry in options.keys) {
      if (options[entry]?.initExpand(provider) ?? false) {
        return true;
      }
    }
    return false;
  }

  int weightCount(List<Optional> radios) {
    int count = 0;
    for (Optional item in radios) {
      count += item.weight;
    }
    return count;
  }

  int offsetIndex(List<Optional> radios, int total, int weightIndex) {
    int left = 0;
    int right = 0;
    for (int i = 0; i < radios.length; i++) {
      left = right;
      right += radios[i].weight;
      if (weightIndex >= left && weightIndex < right) {
        return i;
      }
    }
    return 0;
  }
}
