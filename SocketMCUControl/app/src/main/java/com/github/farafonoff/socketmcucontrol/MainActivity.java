package com.github.farafonoff.socketmcucontrol;

import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import java.net.Socket;

public class MainActivity extends AppCompatActivity implements Button.OnClickListener {
    String TAG = MainActivity.class.toString();
    Intent intent;
    ServiceConnection sConn;
    TextView statusView;
    Button button;
    int gpio = 0;
    boolean status = false;
    TransportBinder socketService;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        intent = new Intent(this, SocketService.class);
        statusView = (TextView)findViewById(R.id.statusView);
        button = (Button) findViewById(R.id.toggleButton);
        button.setOnClickListener(this);
        sConn = new ServiceConnection() {
            @Override
            public void onServiceConnected(ComponentName name, IBinder service) {
                socketService = (TransportBinder) service;
                Log.d(TAG, "Service connected");
                socketService.setStatus(gpio, status);
            }

            @Override
            public void onServiceDisconnected(ComponentName name) {
                Log.d(TAG, "Service disconnected");
                socketService = null;
            }
        };
        bindService(intent, sConn, BIND_AUTO_CREATE);
    }

    @Override
    public void onClick(View v) {
        Log.d(TAG, "BUTTON CLICK");
        this.status = !this.status;
        if (socketService!=null) {
            socketService.setStatus(gpio, status);
        }
    }
}