import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/common/util/string_util.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/bean/Cmd.dart';
import 'package:sd/sd/bean/PromptStyle.dart';
import 'package:sd/sd/bean/UserInfo.dart';
import 'package:sd/sd/bean/Optional.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/const/sp_key.dart';
import 'package:sd/sd/http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

const TAG = "NetWorkProvider";

class NetWorkProvider with ChangeNotifier, DiagnosticableTreeMixin {
  // ServiceConfig config = ServiceConfig();
  UserInfo userInfo = UserInfo();
  Set<String> blackListGroup = Set();
  Optional optional = Optional('');

  Map<String, List<PromptStyle>> publicStyles = Map(); // '','privateFilePath'.''

  FutureOr<int> initServiceConfigIfServiceActive()async{
    int result = 0;
   await get("$sdHttpService$TAG_SERVICE_CONFIG",timeOutSecond: 60,).then((value) {
      if (null != value && value.data != null) {
        cmd = Cmd.fromJson(value.data["cmd"]);
        result= toInt(value.data['serviceVersion'], 0);
        // config = ServiceConfig.fromJson(value.data);
      }
    });
    return result;
  }

  void loadServiceAddressFromGithub(SharedPreferences sp, String configPath) {
    get(configPath, exceptionCallback: (e) {
      //todo 公网配置获取 可能回退 暂时保留
      initNetworkConfig(sp);
    }).then((value) {
      List? services = value?.data['services'];
      if (null != services && services.isNotEmpty) {
        logt(TAG,services.toString());
        sdHttpService = services[0];
      }
      initNetworkConfig(sp);
    });
  }

  void loadOptionalMapFromService(int userAge,String path){
    logt(TAG,"loadOptionalMapFromService $path");
    String? csv;
    get(path,timeOutSecond: 60,exceptionCallback: (e){
      logt(TAG,e.toString());
    }).then((value) {
      if (null != value && null != value.data) {
        csv = value.data.toString();
        List styles = loadPromptStyleFromString(csv!, userAge,groupRecord: publicStyles,extend: true);
        String group='';
        Optional? target;
        for (PromptStyle item in styles) {
          if(item.group!=group){
            group = item.group;
            target = optional.createIfNotExit(blackListGroup,
                group.contains("|") ? group.split('|'): [group],0);
          }
          // if (item.isEmpty) {
            // head = item;
            // logt(TAG," ${target?.name}");

          // } else {
            // logt(TAG," ${target?.name} ${item.name}");
          if(item is Optional) {
            target?.addOption(blackListGroup,item.name, item);
          }
          // }
        }
      }
    });
  }

  void initNetworkConfig(SharedPreferences sp) {
    logt(TAG,"initNetworkConfig $sdShare $sdHost $sdPublicDomain $sdHttpService");

    if (null == sdHttpService || sdHttpService!.isEmpty) {
      sdShare = sp.getBool(SP_SHARE) ?? false;
      logt(TAG,"initNetworkConfig $sdShare $sdHost $sdPublicDomain $sdHttpService");

      if (sdShare!) {
        sdPublicDomain = sp.getString(SP_SHARE_HOST);
        sdHttpService = "https://$sdPublicDomain.gradio.live";
      } else {
        sdHost = sp.getString(SP_HOST) ??
            (UniversalPlatform.isWindows ? SD_WIN_HOST : SD_CLINET_HOST);
        sdHttpService = "http://$sdHost:$SD_PORT";
      }
    } else {
      // sdShare = true;
      // sp.setBool(SP_SHARE, true);
      // sdPublicDomain = sdHttpService!.substring(8, sdHttpService!.length - 13);
      // sp.setString(SP_SHARE_HOST, sdPublicDomain!);
    }

    logt(TAG,"initNetworkConfig $sdShare $sdHost $sdPublicDomain $sdHttpService");
  }

  void initPublicStyleWithNetwork() {
    get("$sdHttpService$GET_STYLES").then((value) async {
      List re = value?.data;
      List<PromptStyle> remote =
          re.map((e) => PromptStyle.fromJson(e)).toList();
      // logt(TAG, re.toString());
      if (remote[0].isEmpty) {
        PromptStyle? head;
        List<PromptStyle> group = [];
        for (PromptStyle item in remote) {
          if (item.isEmpty) {
            if (item != head) {
              if (group.length > 0) {
                publicStyles.putIfAbsent(head!.name, () => group);
                await File("${getStylesPath()}/${head.name}.csv")
                    .writeAsString(const ListToCsvConverter()
                        .convert(PromptStyle.convertPromptStyle(group)));
              }
              group = [];
              head = item;
            }
          } else {
            group.add(item);
          }
        }
      } else {
        publicStyles?.putIfAbsent('remote', () => remote);
      }
      await File("${getStylesPath()}/remote.csv").writeAsString(
          const ListToCsvConverter()
              .convert(PromptStyle.convertPromptStyle(remote)));
    });
  }
}
