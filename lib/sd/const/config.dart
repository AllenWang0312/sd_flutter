// const SD_HTTP_SERVICE = "http://192.168.123.95:7860";

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sd/sd/http_service.dart';
import 'package:universal_platform/universal_platform.dart';

import '../bean/db/History.dart';

const String PACKAGE_NAME = "edu.tjrac.swant.sd";

// theme
const COLOR_BACKGROUND = Color(0xFF0b0b19);
const COLOR_CONTENT_BG = Color(0xFF1f1f37);
const COLOR_ACCENT = Color(0xFFef7400);

const String DEFAULT_SAMPLER = "Euler a";
const String DEFAULT_UPSCALE = "None";

const int DEFAULT_WIDTH = 512;
const int DEFAULT_HEIGHT = 768;

const String DEFAULT_WORKSPACE_NAME = "default";
const int DEFAULT_SAMPLER_STEPS = 30;
const bool DEFAULT_FACE_FIX = false;
const bool DEFAULT_HIRES_FIX = false;
const int WS_COUNT = 3;

// sharedperference
const String SP_SHARE_HOST = 'share_host';
const String SP_HOST = 'host';
const String SP_SHARE = 'share';

const String SP_CURRENT_WS = 'current_ws';
const String SP_WIDTH = "width";
const String SP_HEIGHT = "height";
const String SP_SAMPLER = "sampler";
const String SP_SAMPLER_STEPS = "sampler_steps";
const String SP_CHECKED_STYLES = "checked_styles";
const String SP_AUTO_SAVE = "auto_save";
const String SP_HIDE_NSFW = "hide_nsfw";
const String SP_CHECK_IDENTITY = "check_identity";

const String SP_FACE_FIX = "face_fix";
const String SP_HIRES_FIX = "hires_fix";
const String SP_BATCH_COUNT = "batch_count";
const String SP_BATCH_SIZE = "batch_size";

// routes
const String ROUTE_HOME = "/home";
const String ROUTE_PLUGINS = "/home/plugins";
const String ROUTE_SETTING = "/home/setting";
const String ROUTE_WEBVIEW = "/home/webview";
const String ROUTE_TAVERN = "/home/tavern";

const String ROUTE_STYLE_EDITTING = "/home/setting/styles/edit";
// const String ROUTE_IMAGE_VIEWER = "/viewer";
const String ROUTE_IMAGES_VIEWER = "/home/viewers";
const String ROUTE_CREATE_WORKSPACE = "/home/setting/workspace/create";
const String ROUTE_CREATE_STYLE = "/home/setting/style/create";
const String ROUTE_EDIT_STYLE = "/home/setting/style/edit";
// file system

const String APP_DIR_NAME = 'sdf';

// api

const KEY_HOST = "host";

const SD_WIN_HOST = "127.0.0.1";
const SD_CLINET_HOST = "192.168.0.1";

const SD_PORT = 7860;

placeHolderUrl({int width = 512, int height = 720}) {
  return 'https://via.placeholder.com/$width x$height';
}
  String remoteTXT2IMGDir = '';
  String remoteIMG2IMGDir= '';
  String remoteMoreDir= '';
bool sdShare = false;
String sdShareHost = '';

String sdHost = UniversalPlatform.isWeb
    ? SD_WIN_HOST
    : Platform.isWindows
        ? SD_WIN_HOST
        : SD_CLINET_HOST;

String sdHttpService = '';

const TXT_2_IMG = "/sdapi/v1/txt2img";

const GET_SD_MODELS = "/sdapi/v1/sd-models";

const GET_SAMPLERS = "/sdapi/v1/samplers";

const GET_UPSCALERS = "/sdapi/v1/upscalers";

const GET_STYLES = "/sdapi/v1/prompt-styles";

const GET_OPTIONS = "/sdapi/v1/options";

const RUN_PREDICT = '/run/predict';
const GET_PROGRESS = '/internal/progress';

const FILE_TEMP_PATH = "/file=extensions/tagcomplete/tags/temp";
const TAG_PREFIX_LORA = 'lora';
const TAG_MODELTYPE_LORA = 'Lora';

const TAG_PREFIX_HPE = 'hypernet';
const TAG_MODELTYPE_HPE = 'hypernetworks';

const TAG_PREFIX_EMB = 'emb';
const TAG_MODELTYPE_EMB = 'embding';

const GET_LORA_NAMES = '$FILE_TEMP_PATH/lora.txt';
const GET_EMB_NAMES = '$FILE_TEMP_PATH/emb.txt';
const GET_HYP_NAMES = '$FILE_TEMP_PATH/hyp.txt';
// const GET_WCET_NAMES = '$FILE_TEMP_PATH/wcet.txt';
// const GET_WC_NAMES = '$FILE_TEMP_PATH/wc.txt';
// const GET_WCE_NAMES = '$FILE_TEMP_PATH/wce.txt';

// //platform
// bool isGallerySaverSupportPlatform =
//     UniversalPlatform.isWeb && UniversalPlatform.isAndroid;
//
// getDefaultAutoSavePath() {
//   if (UniversalPlatform.isWeb) {
//     return "/sd";
//   } else if (UniversalPlatform.isAndroid) {
//     return "/storage/emulated/0/Pictures/sd";
//   }
//   return "";
// }

// String urlEncode(String path) {
//   return Uri.encodeFull(path);
//   // return path.replaceAll('\\', '\/').replaceAll(' ', '%20');
// }

//todo imgPath 是否有效 为何无法删除
final String TAG = "config";

History mapToHistory(String remoteDir, int page, int offset, String name) {
  String url = nameToUrl(name);
  logt(TAG, url + " ");
  logt(TAG, " " + name);

  return History(
    // ageLevel: name.contains('18x') ? 18 : 16,
    page: page,
    offset: offset,
    imgUrl: url,
    // imgPath: name.replaceAll('C:\\Users\\Administrator\\AppData\\Local\\Temp',
    //     remoteDir)
  );
}

String nameToUrl(String name) {
  String urlEncode = Uri.encodeFull(name);
  return "$sdHttpService/file=${urlEncode}";
}

getModelImageUrl(String modelType, String name) {
  return sdHttpService + '/file=models/$modelType/' + name + ".png";
}

const GET_DEFAULT_SCRIPTS =
    "/file=extensions/openOutpaint-webUI-extension/app/defaultscripts.json";
