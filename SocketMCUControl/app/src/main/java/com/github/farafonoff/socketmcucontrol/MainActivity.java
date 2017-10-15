package com.github.farafonoff.socketmcucontrol;

import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import java.net.Socket;

public class MainActivity extends AppCompatActivity implements SteeringHandler {
    String TAG = MainActivity.class.toString();
    Intent intent;
    ServiceConnection sConn;
    TextView statusView;
    SteeringSurface steer;
    boolean run = false;
    String carState = "";
    TransportBinder socketService;
    int cn;

    static String build(int r, int l) {
        return String.format("_R%dL%dC%d|",r,l,l^r);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        intent = new Intent(this, SocketService.class);
        statusView = (TextView)findViewById(R.id.statusView);
        steer = (SteeringSurface) findViewById(R.id.steerer);
        steer.setSteeringListener(this);
        sConn = new ServiceConnection() {
            @Override
            public void onServiceConnected(ComponentName name, IBinder service) {
                socketService = (TransportBinder) service;
                Log.d(TAG, "Service connected");
                socketService.setStatus(carState);
            }

            @Override
            public void onServiceDisconnected(ComponentName name) {
                Log.d(TAG, "Service disconnected");
                socketService = null;
            }
        };
        bindService(intent, sConn, BIND_AUTO_CREATE);
    }

    void updateCarState(String s) {
        this.carState = s;
        this.statusView.setText(s);
        this.socketService.setStatus(this.carState);
    }

    @Override
    public void onSteering(float fv, float sv) {
        float velocity = fv * 511.0f;
        if (velocity == 0) {
            float rfactor = sv * 511.0f;
            updateCarState(build(
                    Math.round(rfactor),
                    Math.round(-rfactor)
            ));
        } else {
            if (sv < 0) {
                updateCarState(build(
                        Math.round(velocity + velocity * sv),
                        Math.round(velocity)
                ));
            }
            else {
                updateCarState(build(
                        Math.round(velocity),
                        Math.round(velocity - velocity * sv)
                ));
            }
        }
    }

/*    @Override
    public boolean onTouch(View v, MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN||event.getAction() == MotionEvent.ACTION_HOVER_ENTER ) {
            this.carState = build(255,255);
            this.socketService.setStatus(this.carState);
            return true;
        }
        if (event.getAction() == MotionEvent.ACTION_UP||event.getAction() == MotionEvent.ACTION_HOVER_EXIT ) {
            this.carState = build(0,0);
            this.socketService.setStatus(this.carState);
            return true;
        }
        return false;
    }*/
}
