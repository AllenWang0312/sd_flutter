import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/provider/AppBarProvider.dart';
import 'package:sd/sd/roll/RollModel.dart';
import 'package:sd/sd/roll/roll_widget.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/tavern/tavern_widget.dart';

import '../../common/third_util.dart';
import '../../platform/web_drawer.dart';
import '../MineWidget.dart';
import '../history/history_widget.dart';
import '../history/records_widget.dart';
import '../history/remote_history_widget.dart';
import '../http_service.dart';
import '../widget/StatefulAppBar.dart';
import 'web_home_model.dart';
import '../mocker.dart';
import '../setting/setting_page.dart';

class WebHomePage extends StatefulWidget {
  int? index;

  WebHomePage({super.key, this.index});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  static const TAG = 'WebHomePageState';

  @override
  void didUpdateWidget(WebHomePage oldWidget) {
    logt(TAG, 'didUpdateWidget');
  }

  late List<Widget> pages= [
    // LoraWidget(),
    ChangeNotifierProvider(
      create: (_) => RollModel(),
      child: RollWidget(),
    ),
    HistoryWidget(),
    RemoteHistoryWidget(
      remoteFavouriteDir,
      CMD_FAVOURITE_HISTORY, 'Favorites', //785 12 remote 773 fav 771 del 767
      isFavourite: true,
    ),

    RemoteHistoryWidget(remoteTXT2IMGDir, CMD_GET_TXT2IMG_HISTORY, 'txt2img'),
    //676 remote 679 favourete 666 删除664
    // RemoteHistoryWidget(remoteIMG2IMGDir,CMD_GET_IMG2IMG_HISTORY),
    RemoteHistoryWidget(remoteMoreDir, CMD_GET_MORE_HISTORY, 'Extras'),
    //764 remote 767 favourite 754 delete 752

    SettingPage(),

    // MineWidget(),
  ];
  GlobalKey<RecordsWidgetState> sonKey = GlobalKey();

  // GlobalKey<AppBarState> appbarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  AIPainterModel? provider;

  WebHomeModel? home;
  AppBarProvider? appBar;

  // late IpWidget ipManager;

  Map<dynamic, Function()> getActions(int layoutType) {
    Map<dynamic, Function()> actions = {};
    if (layoutType < 2) {
      actions.putIfAbsent(Icons.search, () => () => {});
    }
    if (layoutType == 2) {
      actions.putIfAbsent(
          Container(
            child: Row(
              children: [
                const Icon(Icons.search),
                // TextField(
                //   decoration: InputDecoration(
                //     hintText: '搜素你的照片',
                //   ),
                //   onTap: () {},
                // )
              ],
            ),
          ),
          () => () => {});
    }

    if (layoutType < 2) {
      actions.putIfAbsent(Icons.upload, () => () => {});
    }
    if (layoutType == 2) {
      actions.putIfAbsent(
          TextButton(onPressed: () {}, child: Text("导入")), () => () => {});
    }
    if (layoutType == 0) {
      actions.putIfAbsent(Icons.more, () => () => {});
    }
    if (layoutType >= 1) {
      actions.putIfAbsent(
          Icons.settings,
          () => () async => {
                if (isMobile() && (await checkStoragePermission()))
                  {provider?.updateIndex(5)}
              });
      actions.putIfAbsent(Icons.menu, () => () => {});
      actions.putIfAbsent(_userPortrait(), () => () => {});
    }
    return actions;
  }

  Widget? getDrawer(int layoutType, double width, double maxWidth) {
    if (layoutType >= 1) {
      return null;
    } else {
      return Column(
        children: _drawerContent(layoutType, width, maxWidth),
      );
    }
  }

  // Key homeKey = Key('homepage');

  // Key drawerKey = Key('drawer');
  static GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    if (null != widget.index) provider?.index = widget.index!;
    home = Provider.of<WebHomeModel>(context, listen: false);
    appBar = Provider.of<AppBarProvider>(context, listen: false);

    appBar?.updateLeadingIcon(home?.layoutType == 0 ? Icons.menu : null, () {

      if(_globalKey.currentState!.isDrawerOpen){
        _globalKey.currentState?.closeDrawer();
      }else{
        _globalKey.currentState?.openDrawer();
      }


    },
        notify: false);
    appBar?.updateTitle(APP_NAME, notify: false);
    appBar?.updateActions(getActions(home?.layoutType ?? 0));


    return LayoutBuilder(builder: (context, cons) {
      double maxWidth = cons.maxWidth;
      home?.updateLayoutType(maxWidth < 480
          ? 0
          : maxWidth < 960
              ? 1
              : 3);

      return Selector<WebHomeModel, int>(
        selector: (_, model) => model.layoutType,
        shouldRebuild: (pre, next) => pre != next,
        builder: (context, layoutType, child) {
          logt(TAG, layoutType.toString());
          return Scaffold(
            key: _globalKey,
              backgroundColor: COLOR_BACKGROUND,
              appBar: PreferredSize(
                  preferredSize: Size(MediaQuery.of(context).size.width, 48),
                  child: Consumer<AppBarProvider>(
                    builder: (_, model, child) {
                      logt(TAG,'appbar config changed');
                      return AppBar(
                        leading: IconButton(
                          icon: Icon(model.leading),
                          onPressed: model.leadingCallback,
                        ),
                        centerTitle: true,
                        title: Text(model.title ?? ""),
                        actions: model.actions == null
                            ? null
                            : remapActionsToWidget(model.actions!),
                      );
                    },
                  )
                  // StatefulAppBar(
                  //   key: appbarKey,
                  //   actions: getActions(layoutType, maxWidth),
                  // ),
                  ),
              drawer: getDrawer(layoutType, 300, maxWidth),
              // onDrawerChanged: ,
              // onEndDrawerChanged: ,
              // drawerDragStartBehavior: ,
              body: Stack(
                children: [

                  Container(
                      margin: EdgeInsets.only(left: getDrawerWidth(layoutType)),
                      child: child!),


                  SizedBox(
                      width: getDrawerWidth(layoutType),
                      child: layoutType==0?null:layoutType == 1||layoutType == 2
                          ? OverflowBox(
                        alignment: Alignment.topLeft,
                        maxWidth: layoutType == 1 ? 60 : 240,
                        child: MouseRegion(
                          onEnter: (_) {
                            logt(TAG,"enter $layoutType");
                            home?.updateLayoutType(2);
                          },
                          onExit: (_) {
                            logt(TAG,"exit $layoutType");
                            home?.updateLayoutType(1);
                          },
                          child: _content(layoutType),
                        ),
                      )
                          : _content(layoutType)),
                ],
              ));
        },
        child: Selector<AIPainterModel, int>(
          selector: (_, model) => model.index,
          shouldRebuild: (pre, next) => pre != next,
          builder: (context, newValue, child) => IndexedStack(
            index: newValue,
            children: pages,
          ),
        ),
      );
    });
  }

  bool mouseEnter = false;

  Widget _content(int layoutType) {
    bool expand = layoutType>=2;
    return Container(
      color: Colors.orange,
      child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: expand ? Text('照片') : null,
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: expand ? Text('探索') : null,
            ),
            ListTile(
              leading: Icon(Icons.group_outlined),
              title: expand ? Text('分享') : null,
            ),
            Container(
              margin: EdgeInsets.only(left: 12),
              height: 24,
              child: expand ?Text( '图片库'):null,
            ),
            ListTile(
              leading: Icon(Icons.star_border_outlined),
              title: expand ? Text('收藏夹') : null,
            ),
            ListTile(
              leading: Icon(Icons.collections_bookmark_outlined),
              title: expand ? Text('影集') : null,
            ),
            ListTile(
              leading: Icon(Icons.check_box_outlined),
              title: expand ? Text('实用工具') : null,
            ),
            ListTile(
              leading: Icon(Icons.file_download_outlined),
              title: expand ? Text('归档') : null,
            ),
            ListTile(
              leading: Icon(Icons.delete_outline),
              title: expand ? Text('回收站') : null,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.cloud_outlined),
              title: expand ? Text('存储空间') : null,
            ),
            if (expand)
              Container(
                margin: EdgeInsets.only(left: 12,top: 8,bottom: 8,right: 12),
                child: LinearProgressIndicator(
                  value: 0.3,
                ),
              ),
            if(expand)
              Container(
                  margin: EdgeInsets.only(left: 12,top: 8,bottom: 8,right: 12),

                  child: Text('已使用3.9GB,共15GB')),
            Spacer(),
            if (expand)
              Container(
                margin: EdgeInsets.only(left: 12,bottom: 12),
                child: Row(
                  children: [
                    Text('隐私权'),
                    Text('·'),
                    Text('条款'),
                    Text('·'),
                    Text('政策'),
                  ],
                ),
              )
          ]),
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

  Widget _userPortrait() {
    return CachedNetworkImage(
        imageUrl: placeHolderUrl(width: 256, height: 256));
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

  List<Widget> _drawerContent(int type, double width, double maxWidth) {
    List<Widget> result = [
      SizedBox(
        height: 48,
        child: Stack(
          children: [
            Positioned(top: 0, bottom: 0, right: 0, child: _userPortrait())
          ],
        ),
      ),
      SizedBox(
        height: 48,
        child: FlutterLogo(),
      ),
    ];
    result.add(_content(3));
    return result;
  }

  double getDrawerWidth(int layoutType) {
    return layoutType == 0
        ? 0
        : layoutType == 1 || layoutType == 2
            ? 60
            : 240;
  }
}
