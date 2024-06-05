import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/pages/home/img2img/prompt_style_picker.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/provider/AppBarProvider.dart';

class SDimg2imgWidget extends StatefulWidget {
  SDimg2imgWidget({super.key});

  @override
  State<SDimg2imgWidget> createState() => _SDimg2imgWidgetState();
}

class _SDimg2imgWidgetState extends State<SDimg2imgWidget> {
  final SDPromptStylePicker promptStylePicker = SDPromptStylePicker();

  Map<IconData, Function()> actions = {};

  AppBarProvider? appBar;

  // const RollWidget();
  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context);
    List<Tab> tabs = provider.optional.options!.keys.map((key) => Tab(text: key)).toList();

    List<Widget> children = provider.optional.options!.values.map((value) => SingleChildScrollView(
        child:
        // provider.styleFrom == 3 ?
        value.generate(provider,0)
      // : generateStyles(provider.publicStyles)
    )).toList();

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: TabBar(
            tabs: tabs,
            isScrollable: true,
            labelStyle: TextStyle(
              fontSize: 16,
            ),
            dividerColor: Colors.transparent,
          ),
        ),
        body: TabBarView(children: children),
      ),
    );
  }
}
