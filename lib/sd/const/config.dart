// const SD_HTTP_SERVICE = "http://192.168.123.95:7860";

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

import '../bean/db/History.dart';
import '../http_service.dart';
import '../mocker.dart';

const String APP_NAME = 'SD Flutter';

const String PACKAGE_NAME = "edu.tjrac.swant.sd";

// theme
const COLOR_BACKGROUND = Color(0xFF0b0b19);
const COLOR_CONTENT_BG = Color(0xFF1f1f37);
const COLOR_ACCENT = Color(0xFFef7400);
const int WS_COUNT = 3;

const String APP_DIR_NAME = 'sdf';
const KEY_HOST = "host";
const SD_WIN_HOST = "127.0.0.1";
const SD_CLINET_HOST = "192.168.0.1";

const SD_PORT = 7860;

placeHolderUrl({int width = 512, int height = 720}) {
  return 'https://via.placeholder.com/$width x$height';
}

const TXT_2_IMG = "/sdapi/v1/txt2img";

const GET_SD_MODELS = "/sdapi/v1/sd-models";

const GET_SAMPLERS = "/sdapi/v1/samplers";

const GET_UPSCALERS = "/sdapi/v1/upscalers";

const GET_STYLES = "/sdapi/v1/prompt-styles";

const GET_OPTIONS = "/sdapi/v1/options";

const RUN_PREDICT = '/run/predict';
const GET_PROGRESS = '/internal/progress';

const FILE_DELEGETE = '/file=extensions';

const TAG_MY_TAGS = '$FILE_DELEGETE/sd_flutter/tags';
const TAG_SERVICE_CONFIG = '$FILE_DELEGETE/sd_flutter/config.json';
const TAG_COMPUTE = '$FILE_DELEGETE/tagcomplete/tags';
const TAG_COMPUTE_CN = '$TAG_COMPUTE/zh_cn.csv';

const FILE_TEMP_PATH = "$FILE_DELEGETE/tagcomplete/tags/temp";
const GET_LORA_NAMES = '$FILE_TEMP_PATH/lora.txt';
const GET_EMB_NAMES = '$FILE_TEMP_PATH/emb.txt';
const GET_HYP_NAMES = '$FILE_TEMP_PATH/hyp.txt';
// const GET_WCET_NAMES = '$FILE_TEMP_PATH/wcet.txt';
// const GET_WC_NAMES = '$FILE_TEMP_PATH/wc.txt';
// const GET_WCE_NAMES = '$FILE_TEMP_PATH/wce.txt';

const TAG_PREFIX_LORA = 'lora';
const TAG_MODELTYPE_LORA = 'Lora';

const TAG_PREFIX_HPE = 'hypernet';
const TAG_MODELTYPE_HPE = 'hypernetworks';

const TAG_PREFIX_EMB = 'emb';
const TAG_MODELTYPE_EMB = 'embding';

//todo imgPath 是否有效 为何无法删除
final String TAG = "config";

History mapToHistory(String remoteDir, int page, int offset, String name) {
  String url = nameToUrl(name);
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

getModelImageUrl(String modelType, String name, {bool preview = true}) {
  return sdHttpService! +
      '/file=models/$modelType/' +
      name +
      (preview ? ".preview" : "") +
      ".png";
}

const GET_DEFAULT_SCRIPTS =
    "/file=extensions/openOutpaint-webUI-extension/app/defaultscripts.json";
