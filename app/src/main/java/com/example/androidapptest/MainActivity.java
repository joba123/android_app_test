package com.example.androidapptest;

import android.app.Activity;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.Button;
import android.widget.FrameLayout;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Button testButton = new Button(this);
        testButton.setText("Test Button");
        testButton.setAllCaps(false);

        FrameLayout.LayoutParams buttonLayoutParams = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER
        );

        FrameLayout rootLayout = new FrameLayout(this);
        rootLayout.addView(testButton, buttonLayoutParams);

        setContentView(rootLayout);
    }
}
