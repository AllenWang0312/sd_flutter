import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../common/third_util.dart';
import '../const/config.dart';
import '../http_service.dart';
import '../mocker.dart';
import '../widget/PageListViewer.dart';
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
const String TAG = "RecordsWidget";
class RecordsWidget extends StatefulWidget {
  RecordsWidget({super.key});

  @override
  State<RecordsWidget> createState() => RecordsWidgetState();
}

class RecordsWidgetState extends State<RecordsWidget>
    with TickerProviderStateMixin {
  List<PageListViewer> children = [
    HistoryWidget(),
    RemoteHistoryWidget(
      remoteFavouriteDir,
      CMD_FAVOURITE_HISTORY,'Favorites',//785 12 remote 773 fav 771 del 767
      isFavourite: true,
    ),

    RemoteHistoryWidget(remoteTXT2IMGDir, CMD_GET_TXT2IMG_HISTORY,'txt2img'),//676 remote 679 favourete 666 删除664
    // RemoteHistoryWidget(remoteIMG2IMGDir,CMD_GET_IMG2IMG_HISTORY),
    RemoteHistoryWidget(remoteMoreDir, CMD_GET_MORE_HISTORY,'Extras'),//764 remote 767 favourite 754 delete 752
  ];

  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: children.length, vsync: this);
    controller.addListener(() {
      logt(TAG,controller.index.toString());
    });
  }

  void returnTopAndRefresh() {

    logt(TAG,controller.index.toString());
    PageListViewer current = children[controller.index];
    current.returnTopAndRefresh();
  }

  @override
  Widget build(BuildContext context) {
    // RecordsModel model =
    //     Provider.of<RecordsModel>(context, listen: false);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                controller: controller,
                tabs: [
                  Tab(text: AppLocalizations.of(context).local),
                  Tab(text: AppLocalizations.of(context).favourite),

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
            controller: controller,
          ),
        )
      ],
    );
  }
}
