import 'package:flutter/material.dart';
import 'plugin_widget.dart';

import '../../config.dart';

class PluginsWidget extends StatelessWidget {

  List<Tab> tabs = [
    Tab(text: "Lora"),
    Tab(text: "Emb"),
    Tab(text: "Hpe"),
    // Tab(text: "Wcet"),
    // Tab(text: "Wc"),
    // Tab(text: "Wce"),
  ];
  List<Widget> children = [
    PluginWidget( TAG_PREFIX_LORA,TAG_MODELTYPE_LORA, GET_LORA_NAMES),
    PluginWidget( TAG_PREFIX_EMB,TAG_MODELTYPE_EMB,GET_EMB_NAMES),
    PluginWidget( TAG_PREFIX_HPE,TAG_MODELTYPE_HPE, GET_HYP_NAMES),
    // TagWidget(GET_WCET_NAMES),
    // TagWidget(GET_WC_NAMES),
    // TagWidget(GET_WCE_NAMES),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: TabBar(
            indicator: null,
            tabs: tabs,
            labelStyle: TextStyle(
              fontSize: 16,
            ),
            dividerColor: Colors.transparent,
          ),
        ),
        body: TabBarView(
            // cacheExtent:3.0,
            children: children),
      ),
    );
  }
}
