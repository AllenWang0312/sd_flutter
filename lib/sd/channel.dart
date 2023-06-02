
import 'package:flutter/services.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

const channel = MethodChannel('flutter.open.native.page');

Future<dynamic> openNativeWebView(String url) async {
  if (UniversalPlatform.isWeb || UniversalPlatform.isMacOS || UniversalPlatform.isWindows) {
    return await launchUrl(Uri.parse(url));
  } else if (UniversalPlatform.isAndroid) {
    // return await channel.invokeMethod(
    //     "edu.tjrac.swant.FlutterFragmentWrapperActivity",
    //     {'moduleName': url, "pageName": url});
    return await channel
        .invokeMethod("edu.tjrac.swant.WebActivity", {'url': url});
  }
  return false;
}