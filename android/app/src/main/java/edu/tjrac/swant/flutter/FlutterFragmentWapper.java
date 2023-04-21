package edu.tjrac.swant.flutter;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import edu.tjrac.swant.sd.R;
import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;

import static edu.tjrac.swant.flutter.FlutterChannelWapper.FLAG_DEFAULT_FLUTTER_ENGINE;

//终端 flutter page wrapper
public class FlutterFragmentWapper extends FragmentActivity {

    final static String TAG_FLUTTER_FRAGMENT = "flutter_fragment";
    final static String TAG_MODULE_NAME = "moduleName";
    final static String TAG_PAGE_NAME = "pageName";
    String moduleName = FLAG_DEFAULT_FLUTTER_ENGINE, pageName = "index";

    private FlutterFragment fragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        if (null != intent) {
            if (intent.hasExtra(TAG_MODULE_NAME))
                moduleName = intent.getStringExtra(TAG_MODULE_NAME);
            if (intent.hasExtra(TAG_PAGE_NAME)) pageName = intent.getStringExtra(TAG_PAGE_NAME);
        }
        setContentView(R.layout.activity_flutter_fragment_wrapper);
        FragmentManager fragmentManager = getSupportFragmentManager();
        fragment = (FlutterFragment) (fragmentManager.findFragmentByTag(TAG_FLUTTER_FRAGMENT));
        if (fragment == null) {
//            fragment = FlutterFragment.createDefault();
            FlutterEngine engine = FlutterEngineCache.getInstance().get(moduleName);
            engine.getNavigationChannel().setInitialRoute("/" + moduleName + "/" + pageName);
            engine.getDartExecutor().executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
            );
            fragment = FlutterFragment.withCachedEngine(moduleName).build();

            fragmentManager.beginTransaction()
                    .add(R.id.fragment_container, fragment, TAG_FLUTTER_FRAGMENT)
                    .commit();
        }
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        fragment.onPostResume();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        fragment.onNewIntent(intent);
        super.onNewIntent(intent);
    }

    @Override
    public void onBackPressed() {
        fragment.onBackPressed();
        super.onBackPressed();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        fragment.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    protected void onUserLeaveHint() {
        super.onUserLeaveHint();
        fragment.onUserLeaveHint();
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        fragment.onTrimMemory(level);
    }
}