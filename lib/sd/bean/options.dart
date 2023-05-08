import 'package:flutter/material.dart';
import 'package:sd/common/Expandable.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import 'PromptStyle.dart';

Optional getOptionalWithName(String n) {
  if (n.endsWith('^')) {
    return One(n, isDetail: n.startsWith('-'));
  } else if (n.endsWith('*')) {
    return OneOrNone(n, isDetail: n.startsWith('-'));
  } else {
    return Optional(n, isDetail: n.startsWith('-'));
  }
}

const TAG = "Optional";

class Optional extends PromptStyle {
  Optional? parent;

  bool? isDetail;

  Optional(super.name,
      {super.prompt, super.negativePrompt, this.isDetail = false});

  String? target;

  Map<String, Optional>? options;

  void addOption(String name, Optional item) {
    if (null == options) {
      options = {};
      if (item is One) {
        target = item.name;
      }
    }
    item.parent = this;
    options!.putIfAbsent(item.name, () => item);
  }

  Optional createIfNotExit(List<String> name) {
    // logt(TAG,this.name + name.toString(),);
    options ??= {};
    Optional option;

    String n = name[0];
    if (options!.keys.contains(n)) {
      option = options![n]!;
    } else {
      option = getOptionalWithName(n);
      addOption(n, option);
    }

    if (name.length > 1) {
      return option.createIfNotExit(name.sublist(1));
    } else {
      return option;
    }
  }

  Widget generate(AIPainterModel provider) {
    Text item = Text(name
        // + (negativeLen > 0 ? "($promptLen/$negativeLen)" : '($promptLen)')
    );
    if (null != options && options!.keys.isNotEmpty) {
      return Expandable(true, item, content(provider, options));
    } else {
      return item;
    }
  }

  @override
  String toString() {
    return 'Optional{isDetail: $isDetail, options: $options}';
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
      return RawChip(
          selected: provider.checkedStyles.contains(e.name),
          onSelected: (bool selected) {
            provider.switchChecked(e.name);
            // e.checked = selected;
          },
          label: Text(e.name));
    }).toList();

    List<Widget> hasChild = [];
    if (noChild.isNotEmpty) {
      hasChild.add(Wrap(
        children: noChild,
      ));
    }
   hasChild.addAll( splits[1].map<Widget>((value) {
     return
       value.generate(provider);
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

class OneOrNone extends Optional {
  OneOrNone(super.name, {super.prompt, super.negativePrompt, super.isDetail});

  @override
  String toString() {
    return 'OneOrNone{isDetail: $isDetail, options: $options}';
  }
}

class One extends Optional {
  One(super.name, {super.prompt, super.negativePrompt, super.isDetail});

  @override
  String toString() {
    return 'One{isDetail: $isDetail, options: $options}';
  }
}
