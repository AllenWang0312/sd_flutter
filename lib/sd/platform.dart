

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

const platform = const MethodChannel('flutter.open.native.page');

Future<bool> openNativeWebView(String url) async {
  if (UniversalPlatform.isWeb || UniversalPlatform.isMacOS || UniversalPlatform.isWindows) {
    return await launchUrl(Uri.parse(url));
  } else if (UniversalPlatform.isAndroid) {
    // return await platform.invokeMethod(
    //     "edu.tjrac.swant.FlutterFragmentWrapperActivity",
    //     {'moduleName': url, "pageName": url});
    return await platform
        .invokeMethod("edu.tjrac.swant.WebActivity", {'url': url});
  }
  return false;
}