package edu.tjrac.swant.flutter;

import android.app.Application;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;

import static edu.tjrac.swant.flutter.FlutterChannelWapper.FLAG_DEFAULT_FLUTTER_ENGINE;

public class SingleFlutterEngineApp extends Application {

    FlutterEngine flutterEngine;

    @Override
    public void onCreate() {
        super.onCreate();
        flutterEngine = new FlutterEngine(this);
        FlutterEngineCache.getInstance()
                .put(FLAG_DEFAULT_FLUTTER_ENGINE, flutterEngine);
    }

    @Override
    public void onTerminate() {
        flutterEngine.destroy();
        super.onTerminate();

    }
}
