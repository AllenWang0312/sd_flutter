package edu.tjrac.swant.flutter

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

//需要具备 flutter channel 能力的 flutter wrapper
class FlutterChannelWapper : FlutterFragmentActivity(), MethodCallHandler {
    // 2. flutter 调用 platform.invokeMethod
    // 3. 原生 onMethodCall 回调
    var moduleName: String? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState) //        getFragmentManager().findFragmentByTag()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) { // 获取系统window支持的模式
            val modes = window.windowManager.defaultDisplay.supportedModes // 对获取的模式，基于刷新率的大小进行排序，从小到大排序
            modes.sortBy{ it.refreshRate }
            window.let{
                val lp = it.attributes // 取出最大的那一个刷新率，直接设置给window

                lp.preferredDisplayModeId = modes.last().modeId
                it.attributes = lp
            }
        }
        val intent = intent
        if (null != intent) {
            Log.d(TAG, "onCreate: " + intent.toURI())
            if (intent.hasExtra(FlutterFragmentWapper.TAG_MODULE_NAME)) {
                moduleName = intent.getStringExtra(FlutterFragmentWapper.TAG_MODULE_NAME)
            }
        }
    }

    override fun getFlutterEngine(): FlutterEngine? { //复用默认engine
        return if (TextUtils.isEmpty(moduleName)) {
            FlutterEngineCache.getInstance()[FLAG_DEFAULT_FLUTTER_ENGINE]
        } else {
            var engine = FlutterEngineCache.getInstance()[moduleName!!]
            if (engine == null) {
                engine = FlutterEngine(this)
                FlutterEngineCache.getInstance().put(moduleName!!, engine)
            }
            engine
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLAG_CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val intent: Intent
        Log.d(TAG, "onMethodCall: " + call.method)
        if (call.method.contains(TAG)) {
            intent = withCachedEngine(call.argument(FlutterFragmentWapper.TAG_MODULE_NAME)!!).build(this)
        } else if (call.method == Intent.ACTION_VIEW) {
            val uri = Uri.parse(call.argument("url"))
            intent = Intent(Intent.ACTION_VIEW, uri)
        } else {
            intent = try {
                Intent(applicationContext, Class.forName(call.method)) //call.method 使用method 参数让flutter 指定跳转Activity
            } catch (e: ClassNotFoundException) {
                throw RuntimeException(e)
            }
            if (call.hasArgument("url")) {
                intent.putExtra("url", call.argument<String>("url"))
            } //            intent.setAction("flutter_open_web");
        }
        startActivity(intent)
    }

    companion object {
        const val FLAG_DEFAULT_FLUTTER_ENGINE = "flutterEngine"
        const val TAG = "ChannelFlutterActivity"

        // 1. 使用此标识 创建 MethodChannel
        const val FLAG_CHANNEL_NAME = "flutter.open.native.page"
    }
}