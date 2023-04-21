import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/playground/history_widget.dart';

import '../../common/third_util.dart';
import '../../common/webview_page.dart';
import '../config.dart';
import 'remote_history_widget.dart';
import 'tavern_widget.dart';

class RecordsModel with ChangeNotifier, DiagnosticableTreeMixin {

  bool dateOrder = true;

  void updateDateOrder(bool order) {
    dateOrder = order;
    notifyListeners();
  }
// int index = 0;
//
// void updateIndex(int index) {
//   this.index = index;
//   notifyListeners();
// }
}

class RecordsWidget extends StatelessWidget {
  RecordsWidget();

  List<Widget> children = [
    // TavernWidget(),
    HistoryWidget(),
    // ChangeNotifierProvider(
    //   create: (_) => EasyRefreshModel(),
    //   child:
    RemoteHistoryWidget(),
    // )
  ];

  @override
  Widget build(BuildContext context) {
    RecordsModel model =
        Provider.of<RecordsModel>(context, listen: false);
    return DefaultTabController(
      length: children.length,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () async {
                    if (await checkStoragePermission()) {
                      Navigator.pushNamed(context, ROUTE_SETTING);
                    }
                    // HistoryWidget(dbController),
                  }),
              Expanded(
                child: TabBar(
                  tabs: [
                    Tab(text: AppLocalizations.of(context).local),
                    Tab(text: AppLocalizations.of(context).remote),
                  ],
                  dividerColor: Colors.transparent,
                ),
              ),
              Selector<RecordsModel, bool>(
                selector: (_, model) => model.dateOrder,
                shouldRebuild: (pre, next) => pre != next,
                builder: (context, newValue, child) {
                  return IconButton(
                      icon: newValue
                          ? const Icon(Icons.date_range_sharp)
                          : const Icon(Icons.fiber_smart_record),
                      onPressed: () {
                        model.dateOrder = !model.dateOrder;
                      });
                },
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: children,
            ),
          )
        ],
      ),
    );
  }
}
