package edu.tjrac.swant;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;

import androidx.annotation.Nullable;
import edu.tjrac.swant.flutter.FlutterChannelWapper;
import edu.tjrac.swant.sd.R;

public class WebActivity extends Activity {

    String url = "https://www.baidu.com";
    WebView web;
    ImageView back,right;
    @SuppressLint({"MissingInflatedId", "SetJavaScriptEnabled"})
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if(getIntent().hasExtra("url")){
            url = getIntent().getStringExtra("url");
        }
        setContentView(R.layout.web);
        web = findViewById(R.id.web);
        WebSettings settings = web.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setUseWideViewPort(true);
        settings.setLoadWithOverviewMode(true);
        settings.setSupportZoom(true);
        settings.setBuiltInZoomControls(true);
        settings.setDisplayZoomControls(false);

        settings.setAllowFileAccess(true);
        settings.setJavaScriptCanOpenWindowsAutomatically(true);
        settings.setLoadsImagesAutomatically(true);
        settings.setDefaultTextEncodingName("utf-8");
        settings.setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);

        back = findViewById(R.id.iv);
        right = findViewById(R.id.iv_right);
        back.setOnClickListener(view -> {
            if(web.canGoBack()){
                web.goBack();
            }else {
                finish();
            }
        });
        right.setOnClickListener(view->{
            //原生跳flutter 暂时不可用
            startActivity(
                    new Intent(this, FlutterChannelWapper.class)
//                    MainActivity
//                            .withCachedEngine("flutterEngine")
//                            .build(this)
            );
        });
        web.setWebViewClient(new WebViewClient(){
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if(url.startsWith("http")){
                    web.loadUrl(url);
                    return true;
                }
                return super.shouldOverrideUrlLoading(view, url);
            }
        });
        web.loadUrl(url);
    }


}
