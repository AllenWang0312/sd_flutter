import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/common/webview/WebControlModel.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../platform/platform.dart';
import '../third_util.dart';
import 'NavigationControls.dart';
import 'const.dart';

const TAG = "WebViewPage";

class WebViewStatefulPage extends StatefulWidget {
  String url;
  String title;
  String? savePath;
  bool debug = false;

  WebViewStatefulPage(this.title, this.url,
      {this.savePath, this.debug = false});

  @override
  State<WebViewStatefulPage> createState() => _WebViewStatefulPageState();
}

class _WebViewStatefulPageState extends State<WebViewStatefulPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..addJavaScriptChannel(
            'Toaster',
            onMessageReceived: (JavaScriptMessage message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message.message)),
              );
            },
          )
          ..loadRequest(Uri.parse(widget.url));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  late WebControlModel model;

  @override
  Widget build(BuildContext context) {
    model = WebControlModel();
    return Scaffold(
      backgroundColor: WEB_BACKGROUND_COLOR,
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      //   actions: <Widget>[
      //     NavigationControls(webViewController: _controller),
      //     if(widget.debug)SampleMenu(webViewController: _controller),
      //   ],
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ChangeNotifierProvider(
          create: (_) => model, child: NavigationControls(_controller)),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
              return false;
            }
            return true;
          },
          child: GestureDetector(
              onLongPressStart: (detail) async {
                if (widget.savePath != null) {
                  String imgUrl =
                      'document.elementFromPoint(${detail.localPosition.dx},${detail.localPosition.dy}).src';
                  _controller
                      .runJavaScriptReturningResult(imgUrl)
                      .then((value) {
                    if (value is String && value != 'null') {
                      PopupMenuItem entry = PopupMenuItem(
                        value: value.replaceAll('"', ''),
                        child: const Wrap(
                            children: [Text('保存至本地'), Icon(Icons.download)]),
                      );
                      RelativeRect position = RelativeRect.fromLTRB(
                          detail.globalPosition.dx,
                          detail.globalPosition.dy,
                          double.infinity,
                          double.infinity);
                      showMenu(
                              context: context,
                              items: [
                                entry,
                              ],
                              position: position)
                          .then((menu) async {
                        // WebDownloader downloader = WebDownloader(
                        //     menu.toString(),
                        //     widget.savePath!,
                        //     getRemoteFileName(widget.title, menu));
                        // String result = await downloader.downloadInBackground();
                        Fluttertoast.showToast(msg:
                        // result
                            saveUrlToLocal(
                                    menu, getRemoteFileNameNoExtend(widget.title, menu),widget.savePath!,domain: widget.title)
                                .toString()
                            );
                        // platform.invokeMethod(
                        //     'android.intent.action.VIEW', {"url": value});
                      });
                    }
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: '需要设置存储目录', gravity: ToastGravity.CENTER);
                }
              },
              child: WebViewWidget(controller: _controller)),
        ),
      ),
    );
  }
}
