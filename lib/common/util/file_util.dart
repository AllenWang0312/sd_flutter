import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:exif/exif.dart';
import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/bean/Optional.dart';
import 'package:sd/sd/db_controler.dart';

import '../../sd/bean/PromptStyle.dart';
import '../../sd/http_service.dart';
import '../../sd/widget/file_prompt_reader.dart';

const TAG = "file util";

// String getPublicPicturesPath(){
//   if(UniversalPlatform.isWeb){
//     return "/";
//   }else if(UniversalPlatform.isAndroid){
//     return ANDROID_PUBLIC_PICTURES_PATH;
//   }else{
//     return "/$APP_DIR_NAME/Pictures";
//   }
// }
// Future<String> getPublicStylesPath()async{
//   return "${await getAutoSaveAbsPath()}/styles";
// }
const EXIF_IMAGE_EXIF_OFFSET_KEY = 'Image ExifOffset';
const EXIF_IMAGE_KEYWORDS_KEY = 'Image XPKeywords';
const EXIF_IMAGE_PADDING_KEY = 'Image Padding';
const EXIF_EXIF_PADDING_KEY = 'EXIF Padding';

Future<List<PromptStyle>> loadPromptStyleFromCSVFile(
    String csvFilePath, int userAge) async {
  String myData = await File(csvFilePath).readAsString();
  logt("loadPromptStyleFromCSVFile", myData);
  return loadPromptStyleFromString(myData, userAge);
}

String group = '';
int limitAge = 0;
int step = 0;
int repet = 1;
int type = 1;
int weight = 1;

List<PromptStyle> loadPromptStyleFromString(String myData, int userAge,
    {Map<String, List<PromptStyle>>? groupRecord, bool extend = false}) {
  logt(TAG, "loadPromptStyleFromString");

  List<List<dynamic>> csvTable = const CsvToListConverter().convert(myData);
  List colums = csvTable.removeAt(0);

  int groupIndex = colums.indexOf(PromptStyle.GROUP);
  int nameIndex = colums.indexOf(PromptStyle.NAME);
  int stepIndex = colums.indexOf(PromptStyle.STEP);
  int typeIndex = colums.indexOf(PromptStyle.TYPE);
  int limitIndex = colums.indexOf(PromptStyle.LIMIT_AGE);
  int promptIndex = colums.indexOf(PromptStyle.PROMPT);
  int negPromptIndex = colums.indexOf(PromptStyle.NEG_PROMPT);
  int weightIndex = colums.indexOf(PromptStyle.WEIGHT);
  int repetIndex = colums.indexOf(PromptStyle.REPET);
  int bListIndex = colums.indexOf(PromptStyle.BLIST);
  int wListIndex = colums.indexOf(PromptStyle.WLIST);
  int reqIndex = colums.indexOf(PromptStyle.REQUIRE);

  return csvTable.where((element) {
    return element.length >= 3 && //过滤空行
        userAge >
            ((limitIndex == -1 ||
                    null == element[limitIndex] ||
                    (element[limitIndex] == ''))
                ? 0
                : element[limitIndex]);
  }).map((dynList) {
    group = getValue(dynList, groupIndex, group);
    late PromptStyle item;
    try {
      String name = getValue(dynList, nameIndex, 'default');
      String? prompt = promptIndex >= 0 && promptIndex < dynList.length
          ? dynList[promptIndex]
          : null;
      String? negPrompt = negPromptIndex >= 0 && negPromptIndex < dynList.length
          ? dynList[negPromptIndex]
          : null;
      String? bList = bListIndex >= 0 && bListIndex < dynList.length
          ? dynList[bListIndex]
          : null;
      String? wList = wListIndex >= 0 && wListIndex < dynList.length
          ? dynList[wListIndex]
          : null;
      String? require =
          reqIndex >= 0 && reqIndex < dynList.length ? dynList[reqIndex] : null;
      //todo 为空继承上一行的属性
      limitAge = toInt(getValue(dynList, limitIndex, limitAge), 0);
      step = toInt(getValue(dynList, stepIndex, step), 0);
      repet = toInt(getValue(dynList, repetIndex, repet), 1);
      type = toInt(getValue(dynList, typeIndex, type), 1);
      weight = toInt(getValue(dynList, weightIndex, weight), 1);

      item = extend
          ? Optional(
              name,
              limitAge: limitAge,
              prompt: prompt,
              negativePrompt: negPrompt,
              group: group,
              step: step,
              type: type,
              repet: repet,
              weight: weight,
              bList: bList,
              wList: wList,
              require: require,
            )
          : PromptStyle(name,
              limitAge: limitAge,
              prompt: prompt,
              negativePrompt: negPrompt,
              group: group,
              step: step,
              type: type,
              repet: repet,
              weight: weight,
              bList: bList,
              wList: wList,
              require: require);
      // logt("loadPromptStyleFromString", item.toString());
    } catch (err) {
      logt("loadPromptStyleFromString", dynList.toString());
    }
    if (null != groupRecord) {
      if (groupRecord.keys.contains(group)) {
        groupRecord[group] ??= [];
        groupRecord[group]?.add(item);
      } else {
        groupRecord.putIfAbsent(group, () => [item]);
      }
    }
    return item;
  }).toList();
}

dynamic getValue(List<dynamic> dynList, int keyIndex, dynamic group) {
  return keyIndex >= 0 && keyIndex < dynList.length ? dynList[keyIndex] : group;
}

Future<String?> getOtherExt(File image, File prompt) async {
  if (prompt.existsSync()) {
    return await prompt.readAsString();
  } else {
    // var bytes = await image.readAsBytes();
    var exif = await readExifFromFile(image);
    // printExifOfBytes(bytes);
    logt(TAG, "jpeg exif:$exif");
    // logt(TAG, "jpeg exif:${}");
    // String tag = utf8.decode(exif[EXIF_IMAGE_KEYWORDS_KEY]!
    //     .values
    //     .toList()
    //     .map((e) => e as int)
    //     .toList());
    // info?.ageLevel = getAgeLevel(tag);
    // prompt.createSync(recursive: true, exclusive: true);
    // prompt.writeAsString(exif.toString()!, encoding: utf8);
    return exif.keys.isEmpty ? null : '';
  }
}

Future<String?> getPngExt(File image, File prompt) async {
  if (prompt.existsSync()) {
    return await prompt.readAsString();
  } else {
    var bytes = await image.readAsBytes();
    try {
      String? ext = getPNGExtData(bytes);
      if (null != ext && ext.isNotEmpty) {
        prompt.createSync(recursive: true, exclusive: true);
        prompt.writeAsString(ext, encoding: utf8);
        return Future.value(ext);
      } else {
        return Future.error('');
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}

bool createDirIfNotExit(String dirPath) {
  Directory dir = Directory(dirPath);
  if (!dir.existsSync()) {
    try {
      dir.createSync(recursive: true);
    } catch (e) {
      logt(TAG, e.toString());
    }
  }
  return dir.existsSync();
}

String getFileName(String absPath) {
  return absPath.substring(absPath.lastIndexOf("/") + 1);
}

String getRemoteFileNameNoExtend(String domain, String url) {
  if (domain.contains('pixai.art')) {
    //domain.contains('krea.ai')||
    return dbString(DateTime.now().toString());
  }
  return url.substring(url.lastIndexOf("/") + 1);
}

String getFileExt(String absPath) {
  return absPath.substring(absPath.lastIndexOf('.')).toLowerCase();
}

bool createFileIfNotExit(File file) {
  if (!file.existsSync()) {
    try {
      file.createSync(recursive: true, exclusive: true); //递归 独占
    } catch (e) {
      logt(TAG, e.toString());
    }
  }
  return file.existsSync();
}

class FromTo {
  String from;
  String to;

  FromTo(this.from, this.to);
}

FutureOr<dynamic> moveDirToAnotherPath(FromTo fromTo) async {
  Directory pubPics = Directory(fromTo.from);
  Directory priPics = Directory(fromTo.to);

  List<FileSystemEntity> entitys = pubPics.listSync();
  try {
    for (FileSystemEntity entity in entitys) {
      if (entity is Directory) {
        await moveChildToAnotherPath(
            getFileName(entity.path), entity.listSync(), priPics);
      }
    }
    logt(TAG, "moveDirToAnotherPath Success");

    return Future.value(1);
  } catch (e) {
    logt(TAG, "moveDirToAnotherPath failed ${e.toString()}");

    return Future.error(-1);
  }
}

Future<void> moveChildToAnotherPath(
    String fileName, List<FileSystemEntity> listSync, Directory priPics) async {
  listSync.forEach((element) async {
    if (element is File) {
      String newPath = "${priPics.path}/$fileName/${getFileName(element.path)}";
      logt(TAG, "${element.path} $newPath");
      await element.copy(newPath);
      await element.delete();
    }
  });
}
