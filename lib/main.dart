import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/splash_page.dart';
import 'package:sd/common/webview/webview_page.dart';
import 'package:sd/platform/android_download_dir_widget.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/const/routes.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/pages/home/home_page.dart';
import 'package:sd/sd/pages/home/txt2img/auto_complate_page.dart';
import 'package:sd/sd/pages/home/txt2img/plgins/plugins_widget.dart';
import 'package:sd/sd/pages/home/txt2img/translate_drag_prompt_widget.dart';
import 'package:sd/sd/pages/imageviewer/ImagesModel.dart';
import 'package:sd/sd/pages/imageviewer/images_viewer.dart';
import 'package:sd/sd/pages/setting/CreateStyleModel.dart';
import 'package:sd/sd/pages/setting/CreateWrokspaceModel.dart';
import 'package:sd/sd/pages/setting/create_style_page.dart';
import 'package:sd/sd/pages/setting/create_workspace_widget.dart';
import 'package:sd/sd/pages/setting/edit_style_page.dart';
import 'package:sd/sd/pages/setting/setting_page.dart';
import 'package:sd/sd/pages/setting/style_edit_page.dart';
import 'package:sd/sd/pages/web/web_home_model.dart';
import 'package:sd/sd/pages/web/web_home_page.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/provider/AppBarProvider.dart';
import 'package:sd/sd/widget/WaitNetworkInterceptor.dart';
import 'package:sd/sd/widget/biological_auth.dart';
import 'package:sd/sd/widget/restartable_widget.dart';

import 'common/third_util.dart';

Map<String, Function> PUBLIC_ROUTES = {
  ROUTE_AUTO_COMPLETE: (context, {arguments}) => _swipeBack(context,
      SDAutoCompleteStatelessPage(arguments['title'], arguments['prompt'])),
  ROUTE_DRAG_PROMPT: (context, {arguments}) => _swipeBack(context,
      SDTranslateDragPromptWidget(arguments['title'], arguments['prompt'])),

  ROUTE_SETTING: (_) => SettingPage(),

  ROUTE_PLUGINS: (context, {arguments}) =>
      _swipeBack(context, const SDPluginsWidget()),
  ROUTE_WEBVIEW: (_, {arguments}) => WebViewStatefulPage(
        arguments['title'],
        arguments['url'],
        savePath: arguments['savePath'],
      ),
  ROUTE_CREATE_WORKSPACE: (_, {arguments}) => ChangeNotifierProvider(
      create: (_) => CreateWSModel(),
      child: SDCreateWorkspaceWidget(
        arguments['imgSavePath'], arguments['styleSavePath'],
// publicPath:arguments['publicPath'],openHidePath: arguments['openHidePath'],
        workspace: arguments['workspace'],
        configs: arguments['configs'],
        publicStyleConfigs: arguments['publicStyleConfigs'],
      )),
  ROUTE_CREATE_STYLE: (_, {arguments}) => ChangeNotifierProvider(
      create: (_) => CreateStyleModel(),
      child: SDCreateStyleWidget(arguments['style'], arguments['autoSaveAbsPath'],
          arguments['files'])),
  ROUTE_STYLE_EDITTING: (_, {arguments}) => SDStyleEditPage(
        arguments['cmd'],
        title: arguments['title'],
        styleName: arguments['styleName'],
        prompt: arguments['prompt'],
        negPrompt: arguments['negPrompt'],
      ),
  ROUTE_EDIT_STYLE: (_, {arguments}) =>
      SDStyleConfigPage(arguments['filePath'], arguments['userAge']),
// ROUTE_IMAGE_VIEWER: (_, {arguments}) => ImageViewer(
//       url: arguments['url'],
//       filePath: arguments['filePath'],
//       bytes: arguments['bytes'],
//   savePath: arguments['savePath'],
//     ),
  ROUTE_IMAGES_VIEWER: (context, {arguments}) => ChangeNotifierProvider(
        create: (_) => ImagesModel(),
        child: _swipeBack(
            context,
            SDImagesViewer(
                autoCancel: arguments['autoCancel'],
                urls: arguments['urls'],
                index: arguments['index'],
                datas: arguments['datas'],
                relativeSaveDirPath: arguments['savePath'],
                scanServiceAvailable: arguments['scanAvailable'] ?? false,
                //todo 是否可以扫描 也应该实时判断
                fnIndex: arguments['fnIndex'] ?? 0,
                isFavourite: arguments['isFavourite'] ?? false,
                type: arguments['type'])),
      )
};

// StatelessWidget _addSafeIfMobile(StatelessWidget child) {
//   if (isMobile()) {
//     return SafeArea(child: child);
//   }
//   return child;
// }

_swipeBack(BuildContext context, StatelessWidget child) {
  return WillPopScope(
      child: child,
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      });
}

Map<String, Function> getMobileRoutes() {
  return mix(PUBLIC_ROUTES, {
    ROUTE_HOME: (_, {arguments}) =>
// ChangeNotifierProvider(
//   create: (_) => HomeModel(),
//   child:
        BiologicalAuthenticaionInterceptor(
            needCheckUserIdentity: true,
            child: WaitNetworkInterceptor(SDHomePage(index: arguments?['index']))),
// ),

    ROUTE_FILE_MANAGER: (_) => AndroidDownloadWidget(),
  });
}

Map<String, Function> getWebRoutes() {
  return mix(PUBLIC_ROUTES, {
    ROUTE_HOME: (_, {arguments}) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => WebHomeModel()),
            ChangeNotifierProvider(create: (_) => AppBarProvider())
          ],
          child: SDWebHomePage(index: arguments?['index']),
        ),
  });
}

Map<String, T> mix<T>(Map<String, T> a, Map<String, T> b) {
  b.forEach((key, value) {
    a.putIfAbsent(key, () => value);
  });
  return a;
}

void main() async {
  _generateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final Function pageContentBuilder =
        (
            // isMobile() ?
            getMobileRoutes()
                // : getWebRoutes()
        )[name!] as Function;
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute(
            builder: (context) =>
                pageContentBuilder(context, arguments: settings.arguments));
        return route;
      } else {
        final Route route = MaterialPageRoute(
            builder: (context) => pageContentBuilder(context));
        return route;
      }
  }

  // logt('isMobile', '${isMobile()}');

  // if(UniversalPlatform.isMacOS){
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await dragAndDropChannel.initializedMainView();
  // }
  runApp(RestartableWidget(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AIPainterModel()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: FToastBuilder(),
          title: 'SD Flutter',

          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            splashColor: COLOR_BACKGROUND,
            brightness: Brightness.dark,
            primaryColor: COLOR_ACCENT,
          ),
          home: SplashPage(),

          onGenerateRoute: _generateRoute,
        )),
  ));
}
