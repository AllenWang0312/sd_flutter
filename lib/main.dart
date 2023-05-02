import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/splash_page.dart';
import 'package:sd/common/webview/webview_page.dart';
import 'package:sd/sd/AIPainterModel.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/pages/HideWhenInactive.dart';
import 'package:sd/sd/pages/home_page.dart';
import 'package:sd/sd/pages/images_viewer.dart';
import 'package:sd/sd/roll/plgins/plugins_widget.dart';
import 'package:sd/sd/setting/CreateStyleModel.dart';
import 'package:sd/sd/setting/CreateWrokspaceModel.dart';
import 'package:sd/sd/setting/create_style_page.dart';
import 'package:sd/sd/setting/create_workspace_widget.dart';
import 'package:sd/sd/setting/edit_style_page.dart';
import 'package:sd/sd/setting/setting_page.dart';
import 'package:sd/sd/setting/style_edit_page.dart';
import 'package:sd/sd/tavern/tavern_widget.dart';
import 'package:sd/sd/widget/restartable_widget.dart';

void main() {
  var routes = {
    ROUTE_HOME: (_, {arguments}) =>
        // ChangeNotifierProvider(
        //   create: (_) => HomeModel(),
        //   child:
        HideWhenInactive(
            needCheckUserIdentity: true,
            child: HomePage(index: arguments?['index'])),
    // ),
    ROUTE_PLUGINS: (_) => const PluginsWidget(),
    ROUTE_SETTING: (_) => SettingPage(),
    ROUTE_TAVERN:(_)=>TavernWidget(),
    ROUTE_WEBVIEW: (_, {arguments}) => WebViewStatefulPage(
      arguments['title'],
      arguments['url'],
      savePath: arguments['savePath'],
    ),
    ROUTE_CREATE_WORKSPACE: (_, {arguments}) => ChangeNotifierProvider(
        create: (_) => CreateWSModel(),
        child: CreateWorkspaceWidget(
          arguments['imgSavePath'], arguments['styleSavePath'],
          // publicPath:arguments['publicPath'],openHidePath: arguments['openHidePath'],
          workspace: arguments['workspace'],
          configs: arguments['configs'],
          publicStyleConfigs: arguments['publicStyleConfigs'],
        )),
    ROUTE_CREATE_STYLE: (_, {arguments}) => ChangeNotifierProvider(
        create: (_) => CreateStyleModel(),
        child: CreateStyleWidget(arguments['style'],
            arguments['autoSaveAbsPath'], arguments['files'])),
    ROUTE_STYLE_EDITTING: (_, {arguments}) => StyleEditPage(
          title: arguments['title'],
          styleName: arguments['styleName'],
          prompt: arguments['prompt'],
          negPrompt: arguments['negPrompt'],
        ),
    ROUTE_EDIT_STYLE: (_, {arguments}) => StyleConfigPage(arguments),
    // ROUTE_IMAGE_VIEWER: (_, {arguments}) => ImageViewer(
    //       url: arguments['url'],
    //       filePath: arguments['filePath'],
    //       bytes: arguments['bytes'],
    //   savePath: arguments['savePath'],
    //     ),
    ROUTE_IMAGES_VIEWER: (_, {arguments}) => ChangeNotifierProvider(
          create: (_) => ImagesModel(),
          child: ImagesViewer(
            urls: arguments['urls'],
            index: arguments['index'],
            datas: arguments['datas'],
            saveDirPath: arguments['savePath'],
            scanServiceAvailable: arguments['scanAvailable'] ?? false,
          ),
        )
  };
  onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final Function pageContentBuilder = routes[name!] as Function;
    if (pageContentBuilder != null) {
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
  }

  runApp(RestartableWidget(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AIPainterModel()),
        ],
        child: MaterialApp(
          // onGenerateTitle: (context) => DemoLocalizations.of(context).title,
          debugShowCheckedModeBanner: false,
          builder: FToastBuilder(),
          title: 'Flutter Demo',

          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // localizationsDelegates: [
          //   AppLocalizations.delegate,
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          //   GlobalCupertinoLocalizations.delegate,
          // ],
          // supportedLocales: [
          //   Locale('en'),
          //   Locale('zh'),
          // ],
          theme: ThemeData(
            splashColor: COLOR_BACKGROUND,
            brightness: Brightness.dark,
            primaryColor: COLOR_ACCENT,
            // textTheme: const TextTheme(
            //   displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            //   titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            //   bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
            // ),
          ),
          home: SplashPage(),
          onGenerateRoute: onGenerateRoute,
        )),
  ));
}
