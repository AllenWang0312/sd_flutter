package edu.tjrac.swant.flutter;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterFragmentActivity;

import static edu.tjrac.swant.flutter.FlutterFragmentWapper.TAG_MODULE_NAME;

//需要具备 flutter channel 能力的 flutter wrapper
public class FlutterChannelWapper extends FlutterFragmentActivity implements MethodChannel.MethodCallHandler {


    static final String FLAG_DEFAULT_FLUTTER_ENGINE = "flutterEngine";

    final static String TAG = "ChannelFlutterActivity";

    // 1. 使用此标识 创建 MethodChannel
    static final String FLAG_CHANNEL_NAME = "flutter.open.native.page";
    // 2. flutter 调用 platform.invokeMethod
    // 3. 原生 onMethodCall 回调


    String moduleName;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        getFragmentManager().findFragmentByTag()
        Intent intent = getIntent();
        if(null!=intent){
            if(intent.hasExtra(TAG_MODULE_NAME)){
                moduleName = intent.getStringExtra(TAG_MODULE_NAME);
            }
        }
    }

    @Nullable
    @Override
    protected FlutterEngine getFlutterEngine() {
        //复用默认engine
        if(TextUtils.isEmpty(moduleName)){
            return FlutterEngineCache.getInstance().get(FLAG_DEFAULT_FLUTTER_ENGINE);
        }else{
           FlutterEngine engine = FlutterEngineCache.getInstance().get(moduleName);
           if(engine==null){
               engine = new FlutterEngine(this);
               FlutterEngineCache.getInstance().put(moduleName,engine);
           }
           return engine;
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), FLAG_CHANNEL_NAME);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Intent intent;
        Log.d(TAG, "onMethodCall: "+call.method);



        if(call.method.contains(TAG)){
            intent = FlutterChannelWapper
                    .withCachedEngine(call.argument(TAG_MODULE_NAME))
                    .build(this);
        }else if(call.method.equals(Intent.ACTION_VIEW)){
            Uri uri = Uri.parse(call.<String>argument("url"));
            intent = new Intent (Intent.ACTION_VIEW, uri);
        }else{
            try {
                intent = new Intent(getApplicationContext(),Class.forName(call.method));//call.method 使用method 参数让flutter 指定跳转Activity
            } catch (ClassNotFoundException e) {
                throw new RuntimeException(e);
            }
            if (call.hasArgument("url")) {
                intent.putExtra("url",call.<String>argument("url"));
            }
//            intent.setAction("flutter_open_web");
        }
        startActivity(intent);
    }
}
