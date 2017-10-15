package com.github.farafonoff.socketmcucontrol;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.support.v4.view.MotionEventCompat;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.SurfaceHolder;

/**
 * Created by farafonoff on 13.10.2017.
 */

public class SteeringSurface extends SurfaceView implements SurfaceHolder.Callback {
    /*static class Drawer implements Runnable {
        SurfaceHolder surfaceHolder;
        public void run() {
            Canvas canvas = surfaceHolder.lockCanvas();
        }
    }*/
    SteeringHandler subscriber;

    public SteeringSurface(Context context, AttributeSet attrs) {
        super(context, attrs);
        getHolder().addCallback(this);
    }

    public void setSteeringListener(SteeringHandler sh) {
        subscriber = sh;
    }

    float px, py;
    boolean ur, ul;

    void reset() {
        px = getWidth()/2;
        py = getHeight()/2;
    }

    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        reset();
        draw(px, py);
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {

    }

    void draw(float x, float y) {
        SurfaceHolder holder = getHolder();
        Canvas canvas = holder.lockCanvas();
        canvas.drawColor(Color.BLACK);
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.LINEAR_TEXT_FLAG);
        paint.setColor(Color.GREEN);
        canvas.drawLine(0, 0, getWidth(), getHeight(), paint);
        canvas.drawLine(0, getHeight(), getWidth(), 0, paint);
        if (ur&&ul)
            paint.setColor(Color.RED);
        if (!ur&&ul)
            paint.setColor(Color.BLUE);
        if (ur&&!ul)
            paint.setColor(Color.YELLOW);
        if (!ur&&!ul)
            paint.setColor(Color.GREEN);
        canvas.drawCircle(x, y, 30, paint);
        holder.unlockCanvasAndPost(canvas);
    }

    void handleEvent(float x, float y) {
        px = x;
        py = y;
        draw(px, py);
        float rx = px / getWidth();
        float ry = py / getHeight();
        ur = rx > ry;
        ul = rx < (1-ry);
        float fv = 0.0f, fs = 0.0f;
        if (ur&&ul) {
            fv = ry - 0.5f;
            fs = rx - 0.5f;
        }
        if (!ur&&!ul) {
            fv = ry - 0.5f;
            fs = rx - 0.5f;
        }
        if (!ur&&ul) {
            fv = 0.0f;
            fs = rx - 0.5f;
        }
        if (ur&&!ul) {
            fv = 0.0f;
            fs = rx - 0.5f;
        }
        if (subscriber != null) {
            subscriber.onSteering(-fv, fs);
        }
        /*if (rx > ry) {
            if (rx < (1-ry)) {

            }
        }*/
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        switch(event.getAction()) {
            case MotionEvent.ACTION_DOWN:
            case MotionEvent.ACTION_MOVE:
                handleEvent(event.getX(), event.getY());
                break;
            case MotionEvent.ACTION_UP:
                reset();
                handleEvent(px, py);
                break;
        }
        return true;
    }
}
