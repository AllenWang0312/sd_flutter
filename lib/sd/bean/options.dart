import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/Expandable.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import 'PromptStyle.dart';

const TAG = "Optional";

class Optional extends PromptStyle {
  int _radioCount = 0;
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
    if (name.endsWith("*")) {
      _radioCount += 1;
    }
    options!.putIfAbsent(item.name, () => item);
    if((name.isNotEmpty||group.isNotEmpty)&&item.group.isEmpty){
      item.group=groupName(group,name);
    }
    if(this.step==null&&item.step!=null){
      step = item.step;
    }
  }

  Optional createIfNotExit(List<String> names, int i) {
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
              (isRadio ||
                      (null != prompt && prompt!.isNotEmpty) ||
                      (null != negativePrompt && negativePrompt!.isNotEmpty))
                  ? Selector<AIPainterModel, List<String>>(
                      selector: (_, model) =>
                          isRadio ? model.checkedRadio : model.checkedStyles,
                      builder: (_, newValue, child) {
                        return ChoiceChip(
                            selectedColor: Colors.grey,
                            label: Text(name),
                            selected: newValue.contains(name),
                            onSelected: (newValue) {
                              if(isRadio){
                                if (newValue) {
                                  //勾选
                                  provider.updateCheckRadio(group, name);
                                } else {
                                  //取消
                                  provider.updateCheckRadio(group, null);
                                }
                              }else{
                                provider.switchChecked(newValue,name);
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
          content(provider, options));
    } else {
      return Text(name);
    }
  }

  void randomChild(AIPainterModel provider) {
    if (
    // step!=0&& todo 过滤还有缺陷
        null != options) {

      Iterable<String> all = options!.keys;
      List<String> others =
          all.where((element) => !element.endsWith("*")).toList();

      bool radioChecked = provider.checkedRadioGroup.contains(groupName(group, name));

      final Random random = Random();


      if (radioChecked) {
        logt(TAG, "random exit radio $group ${provider.checkedRadio[provider.checkedRadioGroup.indexOf(groupName(group, name))]}");


        List<String> radios =
            all.where((element) => element.endsWith("*")).toList();
        logt(TAG, "random radios ${radios.toString()}");

        if(radios.isNotEmpty){
          int index = random.nextInt(radios.length);
          logt(TAG, "random radio $index");

          provider.updateCheckRadio(groupName(group,name), radios[index]);
        }

      }

      int checkCount = 0;
      for (String item in others) {
        if (provider.checkedStyles.contains(item)) {
          provider.checkedStyles.remove(item);
          logt(TAG, "random remove items$item");

          checkCount++;
        }
      }
      if (checkCount > 0 && checkCount != others.length) {
        for (int i = 0; i < checkCount; i++) {
          int ran = random.nextInt(others.length);
          logt(TAG, "random items$ran");
          provider.checkedStyles.add(others[ran]);
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
                  selectedColor: Colors.grey,
                  label: Text(e.name),
                  selected: newValue.contains(e.name),
                  onSelected: (newValue) {
                    logt(TAG,"radio onSelected ${e.group} ${e.name} $newValue");
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
                    logt(TAG, "onSelected $selected ${e.name}",);
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
      return value.generate(provider);
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
    return (group.isEmpty?"":"$group|")+this.name;
  }
}
