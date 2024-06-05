import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/pages/home/chat/chat_page.dart';
import 'package:sd/sd/pages/home/img2img/IMG2IMGModel.dart';
import 'package:sd/sd/pages/home/txt2img/TXT2IMGModel.dart';
import 'package:sd/sd/pages/home/txt2img/txt2img_widget.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../history/records_widget.dart';
import '../../http_service.dart';
import 'img2img/img2img_widget.dart';

const TAG = 'HomePage';

class SDHomePage extends StatelessWidget {
  int? index;

  SDHomePage({super.key, this.index});

  GlobalKey<SDRecordsWidgetState> sonKey = GlobalKey();

  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    if (null != index) provider.index = index!;
    // home = Provider.of<HomeModel>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        backgroundColor: COLOR_BACKGROUND,
        body: Selector<AIPainterModel, int>(
          selector: (_, model) => model.index,
          shouldRebuild: (pre, next) => pre != next,
          builder: (context, newValue, child) => IndexedStack(
            index: newValue,
            children: [
              // LoraWidget(),
              ChangeNotifierProvider(
                create: (_) => TXT2IMGModel(),
                child: SDTXT2IMGWidget(),
              ),
              ChangeNotifierProvider(
                create: (_) => IMG2IMGModel(),
                child: SDimg2imgWidget(),
                // child: ChatPage(),
              ),
              ChangeNotifierProvider(
                create: (_) => RecordsModel(),
                child: SDRecordsWidget(key: sonKey),
              ),
              // MineWidget(),
            ],
          ),
        ),
        bottomNavigationBar: Selector<AIPainterModel, int>(
            selector: (_, model) => model.index,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, newValue, child) {
              return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: newValue,
                items: [
                  // const BottomNavigationBarItem(icon: Icon(Icons.history), label: "Friends"),
                  // BottomNavigationBarItem(
                  //     icon: const Icon(Icons.find_in_page_outlined),
                  //     label: AppLocalizations.of(context).tavern),

                  BottomNavigationBarItem(
                      icon: const Icon(Icons.draw_outlined),
                      label: AppLocalizations.of(context).txt2img),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.image_search),
                      label: AppLocalizations.of(context).img2img),
                  BottomNavigationBarItem(
                      icon: GestureDetector(
                        onDoubleTap: () {
                          logt(TAG, 'onDoubleTap');
                          sonKey.currentState?.returnTopAndRefresh();
                        },
                        child: Icon(Icons.find_in_page_outlined),
                      ),
                      label: AppLocalizations.of(context).history),
                  // BottomNavigationBarItem(
                  //     icon: const Icon(Icons.account_box_outlined),
                  //     label: AppLocalizations.of(context).mine),
                ],
                onTap: (index) {
                  Provider.of<AIPainterModel>(context, listen: false)
                      .updateIndex(index);
                },
              );
              // return BottomAppBar(
              //   shape: const CircularNotchedRectangle(),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //
              //     ],
              //   ),
              // );
            }),
      ),
    );
  }

  // get("$sdHttpService$GET_STYLES").then((value) {
  // List re = value?.data as List;
  // styles = re.map((e) => PromptStyle.fromJson(e)).toList();
  // });

  @override
  void reassemble() {
    logt(TAG, 'reassemble');
  }

  @override
  void activate() {
    logt(TAG, 'activate');
  }

  @override
  void deactivate() {
    logt(TAG, 'deactivate');
  }

  @override
  void didChangeDependencies() {
    logt(TAG, 'didChangeDependencies');
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    logt(TAG, 'debugFillProperties');
  }

// Future<Map<String, dynamic>> asyncDecodeCSVFile() async {
//   final p = ReceivePort();
//   await Isolate.spawn(_readAndParseJson, p.sendPort);
//   return await p.first;
// }
//
// Future _readAndParseJson(SendPort p) async {
//   final fileData = await File(filename).readAsString();
//   final jsonData = jsonDecode(fileData);
//   Isolate.exit(p, jsonData);
// }
}
