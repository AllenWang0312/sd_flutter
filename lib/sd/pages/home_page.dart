import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/config.dart';
import 'package:sd/sd/roll/RollModel.dart';
import 'package:sd/sd/roll/roll_widget.dart';
import 'package:sd/sd/AIPainterModel.dart';
import 'package:sd/sd/tavern/tavern_widget.dart';

import '../history/playground_widget.dart';
import '../http_service.dart';
import '../HomeModel.dart';

const REQUESTING = 1;
const INIT = 0;
const ERROR = -1;

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  static const TAG = 'HomePageState';

  @override
  void didUpdateWidget(HomePage oldWidget) {
    logt(TAG, 'didUpdateWidget');
  }

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      // LoraWidget(),
      TavernWidget(),

      ChangeNotifierProvider(
        create: (_) => RollModel(),
        child: RollWidget(),
      ),
      ChangeNotifierProvider(
        create: (_) => RecordsModel(),
        child: RecordsWidget(),
      ),
      // MineWidget(),
    ];
  }

  late AIPainterModel provider;
  // late HomeModel home;

  // late IpWidget ipManager;
  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    // home = Provider.of<HomeModel>(context, listen: false);
    return DefaultTabController(
        length: 4,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: COLOR_BACKGROUND,
            bottomNavigationBar: Selector<HomeModel, int>(
                selector: (_, model) => model.index,
                shouldRebuild: (pre, next) => pre != next,
                builder: (context, newValue, child) {
                  return BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: newValue,
                    items: [
                      // const BottomNavigationBarItem(icon: Icon(Icons.history), label: "Friends"),
                      BottomNavigationBarItem(
                          icon: const Icon(Icons.find_in_page_outlined),
                          label: AppLocalizations.of(context).tavern),

                      BottomNavigationBarItem(
                          icon: const Icon(Icons.draw_outlined),
                          label: AppLocalizations.of(context).roll),
                      BottomNavigationBarItem(
                          icon: const Icon(Icons.find_in_page_outlined),
                          label: AppLocalizations.of(context).history),
                      // BottomNavigationBarItem(
                      //     icon: const Icon(Icons.account_box_outlined),
                      //     label: AppLocalizations.of(context).mine),
                    ],
                    onTap: (index) {
                      Provider.of<HomeModel>(context, listen: false)
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
            body: Selector<HomeModel, int>(
              selector: (_, model) => model.index,
              shouldRebuild: (pre, next) => pre != next,
              builder: (context, newValue, child) => IndexedStack(
                index: newValue,
                children: pages,
              ),
            ),
          ),
        ));
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
  Future<void> dispose() async {
    logt(TAG, 'dispose');
    super.dispose();
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
