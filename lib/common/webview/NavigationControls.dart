import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'WebControlModel.dart';
import 'const.dart';

class NavigationControls extends StatelessWidget {
  final WebViewController webViewController;

  NavigationControls(this.webViewController) {
    webViewController.setNavigationDelegate(NavigationDelegate(
      onProgress: (int progress) {
        if (progress == 100) {
          model.updateProgress(null);
        } else {
          model.updateProgress(progress / 100.0);
        }
      },
      onPageStarted: (String url) {
        debugPrint('Page started loading: $url');
      },
      onPageFinished: (String url) {
        model.updateCurrentUrl(url);
      },
      onWebResourceError: (WebResourceError error) {
        debugPrint('''Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
      },
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          debugPrint('blocking navigation to ${request.url}');
          return NavigationDecision.prevent;
        }
        debugPrint('allowing navigation to ${request.url}');
        return NavigationDecision.navigate;
      },
    ));
  }

  late WebControlModel model;

  @override
  Widget build(BuildContext context) {
    model = Provider.of<WebControlModel>(context, listen: false);
    return Container(
      color: WEB_BACKGROUND_COLOR,
      child: Stack(
        children: [
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  if (await webViewController.canGoBack()) {
                    await webViewController.goBack();
                    model.updateCurrentUrl(await webViewController.currentUrl());
                  } else {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () async {
                  if (await webViewController.canGoForward()) {
                    await webViewController.goForward();
                    model.updateCurrentUrl(await webViewController.currentUrl());
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No forward history item')),
                      );
                    }
                  }
                },
              ),
              Expanded(
                  child: Selector<WebControlModel, String?>(
                      selector: (_, model) => model.url,
                      builder: (context, value, child) {
                        return TextFormField(
                          initialValue: value ?? "",
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        );
                      })),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: () => webViewController.reload(),
              ),
              IconButton(
                  onPressed: () async {
                    final String? url = await webViewController.currentUrl();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Favorited $url')),
                      );
                    }
                  },
                  icon: Icon(Icons.favorite))
            ],
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Selector<WebControlModel, double?>(
                selector: (_, model) => model.progress,
                builder: (context, value, child) {
                  return Offstage(
                    offstage: value == null,
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 4,
                      backgroundColor: WEB_BACKGROUND_COLOR,
                      color: Colors.yellow,
                    ),
                  );
                },
              ))
        ],
      ),
    );
  }
}
