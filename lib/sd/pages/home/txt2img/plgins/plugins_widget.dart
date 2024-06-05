import 'package:flutter/material.dart';
import '../../../../const/config.dart';
import 'plugin_widget.dart';

class SDPluginsWidget extends StatelessWidget {
  const SDPluginsWidget();

  static const List<Tab> tabs = [
    Tab(text: "主模"),
    Tab(text: "Lora"),
    Tab(text: "Emb"),
    Tab(text: "Hpe"),
    // Tab(text: "Wcet"),
    // Tab(text: "Wc"),
    // Tab(text: "Wce"),
  ];
  static const List<Widget> children = [
    SDPluginWidget(TAG_PREFIX_ENDPOINTS, TAG_MODELTYPE_ENDPOINTS),
    SDPluginWidget(TAG_PREFIX_LORA, TAG_MODELTYPE_LORA, nameFilePath: GET_LORA_NAMES),
    SDPluginWidget(TAG_PREFIX_EMB, TAG_MODELTYPE_EMB, nameFilePath: GET_EMB_NAMES),
    SDPluginWidget(TAG_PREFIX_HPE, TAG_MODELTYPE_HPE, nameFilePath: GET_HYP_NAMES),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: const TabBar(
            tabs: tabs,
            labelStyle: TextStyle(
              fontSize: 16,
            ),
            dividerColor: Colors.transparent,
          ),
        ),
        body: const TabBarView(
            children: children),
      ),
    );
  }
}
