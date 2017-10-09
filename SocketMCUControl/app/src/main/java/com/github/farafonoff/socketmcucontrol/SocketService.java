package com.github.farafonoff.socketmcucontrol;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.Socket;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class SocketService extends Service {
    String TAG = SocketService.class.toString();
    Thread socketThread;
    ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
    TransportBinder binder;
    Worker worker;
    public SocketService() {
        worker = new Worker();
        socketThread = new Thread(worker);
        binder = new TransportBinder(this);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    public void setStatus(final int gpio, final boolean on) {
        ses.execute(new Runnable() {
            public void run() {
                worker.setStatus(gpio, on);
            }
        });
    }

    class Worker implements Runnable {
        Worker() {
            try {
                remote = Inet4Address.getByName("192.168.4.1");
                clientSocket = new DatagramSocket();
            } catch (SocketException e) {
                e.printStackTrace();
            } catch (UnknownHostException e) {
                e.printStackTrace();
            }
        }

        DatagramSocket clientSocket;
        InetAddress remote;
        byte[] sendbuf = new byte[20];

        synchronized void getStatus() {
            sendbuf[0] = 0;
            send(1);
        }

        void send(int len) {
            try {
                clientSocket.send(new DatagramPacket(sendbuf, 2, remote, 1234));
            } catch (IOException e) {
                Log.e(TAG, e.toString());
            }
        }

        synchronized void setStatus(int gpio, boolean on) {
            sendbuf[0] = (byte)(on?1:2);
            sendbuf[1] = (byte)gpio;
            Log.d(TAG, String.format("Set gpio %d to %B", gpio, on));
            send(2);
        }

        @Override
        public void run() {
            byte[] buffer = new byte[1000];
            while(true) {
                DatagramPacket recv = new DatagramPacket(buffer, buffer.length);
                try {
                    clientSocket.receive(recv);
                    System.err.println(recv.getLength());
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
