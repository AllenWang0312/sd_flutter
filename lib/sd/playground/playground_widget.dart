import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/playground/history_widget.dart';
import 'remote_history_widget.dart';
import 'tavern_widget.dart';

class PlaygroundModel with ChangeNotifier, DiagnosticableTreeMixin {
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

class PlaygroundWidget extends StatelessWidget {

  PlaygroundWidget();

  List<Tab> tabs = [
    Tab(text: "酒馆"),
    Tab(text: "本地"),
    Tab(text: "远端"),
  ];
  List<Widget> children = [ TavernWidget(),
    HistoryWidget(),
    RemoteHistoryWidget()];

  @override
  Widget build(BuildContext context) {
    PlaygroundModel model = Provider.of<PlaygroundModel>(
        context, listen: false);
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  tabs: tabs,
                  dividerColor: Colors.transparent,
                ),
              ),
              Selector<PlaygroundModel, bool>(
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
              children:children,
            ),
          )
        ],
      ),
    );
  }
}
