package com.github.farafonoff.socketmcucontrol;

import android.content.Context;
import android.support.v7.widget.AppCompatButton;
import android.text.method.Touch;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.Button;

import org.w3c.dom.Attr;

/**
 * Created by Artem_Farafonov on 10/13/2017.
 */

public class TouchButton extends AppCompatButton {
    TouchButton(Context ctx) {
        super(ctx);
    }
    TouchButton(Context ctx, AttributeSet attrs) {
        super(ctx, attrs);
    }
    TouchButton(Context ctx, AttributeSet attrs, int defStyleAttr) {
        super(ctx, attrs, defStyleAttr);
    }

    @Override
    protected boolean dispatchHoverEvent(MotionEvent event) {
        switch(event.getAction()) {
            
        }
        return super.dispatchHoverEvent(event);
    }
}
