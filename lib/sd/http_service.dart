import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd/sd/bean/Cmd.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:universal_platform/universal_platform.dart';

import 'const/config.dart';

int userAge = 1000;
bool sfw = userAge < 18;
//todo 热更新后不会清空值
bool? sdShare = false;
String? sdPublicDomain = null;
String? sdHttpService = null;
// bool? sdShare = true;
// String? sdPublicDomain = "6e4c2aa6-9925-41fc";
// String? sdHttpService = "https://$sdPublicDomain.gradio.live";

String sdHost = UniversalPlatform.isWeb || Platform.isWindows
    ? SD_WIN_HOST
    : SD_CLINET_HOST;
bool PROXY = false;

String remoteTXT2IMGDir = '';
String remoteIMG2IMGDir = '';
String remoteMoreDir = '';
String remoteFavouriteDir = '';

Cmd cmd = Cmd();
int serviceVersion = 0;

// String sdShareHost = 'https://huggingface.co/spaces';
logd(String msg) {
  log(msg, level: 0); // 待验证release是否不打印
  // if (kDebugMode) {
  //   print(msg);
  // }
}

logt(String tag, String msg) {
  log("$tag:$msg", level: 0); // 待验证release是否不打印
  // if (kDebugMode) {
  //   print();
  // }
}

const HTTP_TIME_OUT = 10 * 60;

final String TAG = "http_service";

Future<String> download(String url, String savePath,
    {Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress}) async {
  logt(TAG, "download img url:$url savePath:$savePath");

  try {
    await Dio().download(url, savePath,
        queryParameters: queryParams,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
  } on DioError catch (e) {
    if (CancelToken.isCancel(e)) {
      logt(TAG, e.toString());
      Fluttertoast.showToast(msg: '下载已取消！$e');
    } else {
      logt(TAG, e.toString());

      Fluttertoast.showToast(msg: '下载失败！$e');
    }
  } on Exception catch (e) {
    logt(TAG, e.toString());

    Fluttertoast.showToast(msg: '下载失败！$e');
  }
  return savePath;
}

Future<Response?> get(url,
    {formData,
    int timeOutSecond = HTTP_TIME_OUT,
    dynamic headers,
    Function? exceptionCallback}) async {
  logt(TAG, "get:$url");
  try {
    Response response;
    Dio dio = Dio(baseOptions(timeOutSecond, headers: headers));
    if (PROXY) addProxy(dio);
    if (formData == null) {
      response = await dio.get(url);
    } else {
      response = await dio.get(url, queryParameters: formData);
      logt(TAG, "get:$formData");
    }
    return catchError(response, exceptionCallback);
  } catch (e) {
    logt(TAG, "get err: $e");
    despatchErrorInfo(400,dioErrorMessage: e.toString(),callback: exceptionCallback);

    return Future(() => null);
  }
}

Future<Response?> post(url,
    {formData,
    int timeOut = HTTP_TIME_OUT,
    dynamic headers,
    Function? exceptionCallback,
    NetWorkStateProvider? provider}) async {
  logt(TAG, "post:$url");
  try {
    Response response;
    Dio dio = Dio(baseOptions(timeOut, headers: headers));
    if (PROXY) addProxy(dio);
    provider?.updateNetworkState(REQUESTING);

    if (formData == null) {
      response = await dio.post(url);
    } else {
      response = await dio.post(url, data: formData);
      logt(TAG, "post:${formData}");
    }
    return catchError(response, exceptionCallback);
  } catch (e) {
    logt(TAG, "post err:$e");
    provider?.updateNetworkState(REQUEST_ERROR);
    despatchErrorInfo(400,dioErrorMessage: e.toString(),callback: exceptionCallback);
    return Future(() => null);
  }
}

Future<Response?> catchError(Response response, Function? callback) async {
  if (response.statusCode! < 400) {
    return response;
  } else {
    despatchErrorInfo(response.statusCode,
        dioErrorMessage: "网络异常 ${response.statusMessage}", callback: callback);
    return null;
  }
}

void despatchErrorInfo(int? statusCode,
    {String? dioErrorMessage, Function? callback}) {
  String? message;
  switch (statusCode) {
    case 401:
    //   message = "您暂无权限查看，如需申请权限请联系管理员";
      break;
    case 404:
      message = "系统错误，请稍后再试";
      break;
    case 406:
      message = "系统错误，请稍后再试";
      break;
    case 410:
      message = "该内容已被管理员删除";
      break;
    case 422:
      message = "您的账户已被停用";
      break;
    default:
    // message = "系统错误，请联系管理员进行反馈，或稍后重试"; //400、403、500、502、503、504
      break;
  }
  if (statusCode == 401 || dioErrorMessage?.contains(" 401 ") == true) {
    // updateStringCache("userTicket", "");
    // NativeHelper.toLogin();
    // NativeHelper.closeCurrent();
  } else {
    if (message?.isNotEmpty == true) {
      Fluttertoast.showToast(msg: message!, gravity: ToastGravity.CENTER);
    } else {
      // Fluttertoast.showToast(msg: '请求失败！${dioErrorMessage}');
      logd('请求失败！${dioErrorMessage}');
    }
  }

  onError(statusCode, dioErrorMessage, callback: callback);
}

void onError(int? statusCode, String? statusMessage, {Function? callback}) {
  dynamic err = {'code': statusCode, 'errMsg': statusMessage};
  if (null != callback) {
    callback(err);
  }
}

void addProxy(Dio dio) {
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.findProxy = (uri) {
      //proxy all request to localhost:8888
      // return "PROXY 10.10.2.22:8888";
      return "PROXY 192.168.0.110:8888";
    };
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  };
}

BaseOptions? baseOptions(int timeOutSeconds, {dynamic headers}) {
  BaseOptions options = BaseOptions(
      sendTimeout: Duration(seconds: timeOutSeconds),
      receiveTimeout: Duration(seconds: timeOutSeconds));
  if (null != headers) {
    options.headers = headers;
  }
  return options;
}

// abstract class NESubscriber {
//  dynamic response;
//
//  NESubscriber(this.response){
//
//  }
//
//  onSuccess(dynamic data){
//
//  }
//  onError(Error error);
//
//  onComplate();
// }
