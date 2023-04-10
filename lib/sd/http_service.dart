import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fluttertoast/fluttertoast.dart';

bool PROXY = false;

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
final String TAG = "http_service";

Future<String> download(String url, String savePath,
    {Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress}) async {
  try {
    await Dio().download(url, savePath,
        queryParameters: queryParams,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
  } on DioError catch (e) {
    if (CancelToken.isCancel(e)) {
      logt(TAG,e.toString());
      Fluttertoast.showToast(msg: '下载已取消！$e');
    } else {
      logt(TAG,e.toString());

      Fluttertoast.showToast(msg: '下载失败！$e');
    }
  } on Exception catch (e) {
    logt(TAG,e.toString());

    Fluttertoast.showToast(msg: '下载失败！$e');
  }
  return savePath;
}

Future<Response?> get(url, {formData, Function? exceptionCallback}) async {
  logt(TAG,"get:$url");
  try {
    Response response;
    Dio dio = Dio(baseOptions());
    if (formData == null) {
      response = await dio.get(url);
    } else {
      response = await dio.get(url, queryParameters: formData);
      logt(TAG,"get:$formData");
    }
    return catchError(response, exceptionCallback);
  } catch (e) {
    if (null != exceptionCallback) {
      exceptionCallback(e);
    }
    return Future.error({'code': -1, 'errMsg': e.toString()});
  }
}

Future<Response?> post(url, {formData, Function? exceptionCallback}) async {
  logt(TAG,"post:$url");
  try {
    Response response;
    Dio dio = Dio(baseOptions());
    if (formData == null) {
      response = await dio.post(url);
    } else {
      response = await dio.post(url, data: formData);
      logt(TAG,"post:${formData}");
    }
    return catchError(response, exceptionCallback);
  } catch (e) {
    if (null != exceptionCallback) {
      exceptionCallback(e);
    }
    return Future.error({'code': -1, 'errMsg': e.toString()});
  }
}

Future<Response?> catchError(Response response, Function? callback) async {
  if (response.statusCode == 200) {
    return response;
  } else {
    dynamic err = {
      'code': response.statusCode,
      'errMsg': response.statusMessage
    };
    if (null != callback) {
      callback(err);
    }
    return Future.error(err);
  }
}

void addProxy(Dio dio) {
  if (PROXY) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.findProxy = (uri) {
        //proxy all request to localhost:8888
        return "PROXY 10.10.2.22:8888";
        // return "PROXY 192.168.0.110:8888";
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
  }
}

BaseOptions? baseOptions() {
  return BaseOptions(
      sendTimeout: const Duration(seconds: 60*10),
      receiveTimeout: const Duration(seconds: 60*10));
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
