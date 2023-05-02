import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../common/third_util.dart';
import '../const/config.dart';
import '../mocker.dart';
import 'history_widget.dart';
import 'remote_history_widget.dart';

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
    const HistoryWidget(),
    RemoteHistoryWidget(remoteTXT2IMGDir,CMD_GET_TXT2IMG_HISTORY),
    // RemoteHistoryWidget(remoteIMG2IMGDir,CMD_GET_IMG2IMG_HISTORY),
    RemoteHistoryWidget(remoteMoreDir,CMD_GET_MORE_HISTORY),
  ];

  @override
  Widget build(BuildContext context) {
    // RecordsModel model =
    //     Provider.of<RecordsModel>(context, listen: false);
    return DefaultTabController(
      length: children.length,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  tabs: [
                    Tab(text: AppLocalizations.of(context).local),
                    Tab(text: AppLocalizations.of(context).remoteTxt2Img),
                    // Tab(text: AppLocalizations.of(context).remoteImg2Img),
                    Tab(text: AppLocalizations.of(context).extras),
                  ],
                  dividerColor: Colors.transparent,
                ),
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
