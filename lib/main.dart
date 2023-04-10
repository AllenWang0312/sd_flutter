import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/splash_page.dart';
import 'package:sd/sd/config.dart';
import 'package:sd/sd/model/AIPainterModel.dart';
import 'package:sd/sd/model/HomeModel.dart';
import 'package:sd/sd/pages/create_style_page.dart';
import 'package:sd/sd/pages/create_workspace_widget.dart';
import 'package:sd/sd/pages/home_page.dart';
import 'package:sd/sd/pages/image_viewer.dart';
import 'package:sd/sd/pages/images_viewer.dart';
import 'package:sd/sd/pages/setting_page.dart';
import 'package:sd/sd/pages/style_edit_page.dart';
import 'package:sd/sd/plgins/plugins_widget.dart';
import 'package:sd/sd/widget/restartable_widget.dart';

void main() {
  var routes = {
    ROUTE_HOME: (_, {arguments}) => ChangeNotifierProvider(
          create: (_) => HomeModel(),
          child: HomePage(),
        ),
    ROUTE_PLUGINS: (_) => PluginsWidget(),
    ROUTE_SETTING: (_) => SettingPage(),
    ROUTE_CREATE_WORKSPACE: (_, {arguments}) => ChangeNotifierProvider(
        create: (_) => CreateWSModel(),
        child: CreateWorkspaceWidget(arguments['applicationPath'],
            arguments['publicPath'], arguments['openHidePath'],
            workspace: arguments['workspace'])),
    ROUTE_CREATE_STYLE: (_, {arguments}) => ChangeNotifierProvider(
        create: (_) => CreateStyleModel(),
        child: CreateStyleWidget(
          arguments['applicationPath'],
          arguments['publicPath'],
          arguments['openHidePath'],
          style: arguments['style'],
        )),
    ROUTE_STYLE_EDITTING: (_, {arguments}) => StyleEditPage(
          title: arguments['title'],
          styleName: arguments['styleName'],
          prompt: arguments['prompt'],
          negPrompt: arguments['negPrompt'],
        ),
    ROUTE_IMAGE_VIEWER: (_, {arguments}) => ImageViewer(
          url: arguments['url'],
          filePath: arguments['filePath'],
          bytes: arguments['bytes'],
        ),
    ROUTE_IMAGES_VIEWER: (_, {arguments}) => ImagesViewer(
          urls: arguments['urls'],
          datas: arguments['datas'],
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
          debugShowCheckedModeBanner: false,
          builder: FToastBuilder(),
          title: 'Flutter Demo',
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
