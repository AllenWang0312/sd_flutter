package edu.tjrac.swant.flutter

import android.Manifest
import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class SingleFlutterEngineApp : Application() {
    var flutterEngine: FlutterEngine? = null
    override fun onCreate() {
        super.onCreate()
        val perms = arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE,Manifest.permission.WRITE_EXTERNAL_STORAGE)

        for(p in perms){
        }
        flutterEngine = FlutterEngine(this)
        FlutterEngineCache.getInstance()
            .put(FlutterChannelWapper.FLAG_DEFAULT_FLUTTER_ENGINE, flutterEngine)
    }

    override fun onTerminate() {
        flutterEngine?.destroy()
        super.onTerminate()
    }
}