import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/widget/LifecycleState.dart';

import '../../common/util/ui_util.dart';
import '../provider/AIPainterModel.dart';
import '../http_service.dart';

const TAG = "HideWhenInactive";
class BiologicalAuthenticaionInterceptor extends StatefulWidget {
  Widget child;
  bool needCheckUserIdentity; //是否需要校验身份才能使用

  BiologicalAuthenticaionInterceptor({this.needCheckUserIdentity = false, required this.child});

  @override
  State<StatefulWidget> createState() {
    return _BiologicalAuthenticaionInterceptorState();
  }
}

class _BiologicalAuthenticaionInterceptorState extends LifecycleState<BiologicalAuthenticaionInterceptor>
     {
  bool canAuthenticateWithBiometrics = false;
  final LocalAuthentication auth = LocalAuthentication();
  late List<BiometricType>? availableBiometrics;
  late AIPainterModel provider;

  bool showFilter  = false;
  bool isDialog = false;

  @override
  void initState() {
    super.initState();
    initLocalAuth();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    return Stack(
      children: [
        widget.child,
        if(showFilter)BackdropFilter(
          filter: CHECK_IDENTITY,
          child: const SizedBox.expand(),
        )
      ],
    );
  }



  Future<void> initLocalAuth() async {
    canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    if (canAuthenticate) {
      availableBiometrics = await auth.getAvailableBiometrics();
    }
    // if (availableBiometrics.contains(BiometricType.strong) ||
    //     availableBiometrics.contains(BiometricType.face)) {
    //   // Specific types of biometrics are available.
    //   // Use checks like this with caution!
    // }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // logt(TAG, "resumed");
      // initData(true);
      if (widget.needCheckUserIdentity &&
          provider.checkIdentityWhenReEnter &&
          availableBiometrics != null &&
          availableBiometrics!.isNotEmpty&&!isDialog) {
        showDialog(
            barrierDismissible: false,
            // useRootNavigator:false;
            context: context,
            builder: (context) {
              isDialog = true;
              return WillPopScope(// 禁止滑动取消dialog
                onWillPop: ()async{
                  return false;
                },
                child: Center(
                  child: AlertDialog(
                    title: const Text('身份认证'),
                    content: const Text('您是本机的主人吗'),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            try {
                              final bool didAuthenticate = await auth.authenticate(
                                  localizedReason: '应用开启离开认证 需要验证您的身份',
                                  options: const AuthenticationOptions(
                                      biometricOnly: true));
                              if (didAuthenticate) {
                                setState(() {
                                  showFilter = false;
                                  isDialog = false;
                                });
                                if(context.mounted)Navigator.pop(context);
                              }
                            } on PlatformException catch (e) {
                              if (e.code == auth_error.notEnrolled) {
                              } else if (e.code == auth_error.lockedOut ||
                                  e.code == auth_error.permanentlyLockedOut) {
                              } else {}
                            }
                          },
                          child: const Text('开始识别'))
                    ],
                  ),
                ),
              );
            });
      }else{
        setState(() {
          showFilter = false;
        });
      }
    } else if (state == AppLifecycleState.inactive) {
      logt(TAG, "inactive");

    } else if (state == AppLifecycleState.paused) {
      logt(TAG, "paused");
      if (widget.needCheckUserIdentity &&
          provider.checkIdentityWhenReEnter &&
          availableBiometrics != null &&
          availableBiometrics!.isNotEmpty) {
        setState(() {
          showFilter = true;
        });
      }
    } else if (state == AppLifecycleState.detached) {
      logt(TAG, "detached");
    }
  }
}
