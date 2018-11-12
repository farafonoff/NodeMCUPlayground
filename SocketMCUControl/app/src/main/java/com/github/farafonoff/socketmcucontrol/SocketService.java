package com.github.farafonoff.socketmcucontrol;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.net.DhcpInfo;
import android.net.wifi.WifiManager;
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
import java.nio.charset.Charset;
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
        socketThread.start();
        binder = new TransportBinder(this);
        ses.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                worker.discover();
                worker.send(worker.sendbuf.length);
            }
        }, 1,1, TimeUnit.SECONDS);
    }

    InetAddress getBroadcastAddress() throws IOException {
        WifiManager wifi = (WifiManager) this.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        DhcpInfo dhcp = wifi.getDhcpInfo();
        // handle null somehow

        int broadcast = (dhcp.ipAddress & dhcp.netmask) | ~dhcp.netmask;
        byte[] quads = new byte[4];
        for (int k = 0; k < 4; k++)
            quads[k] = (byte) ((broadcast >> k * 8) & 0xFF);
        return InetAddress.getByAddress(quads);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    public void setStatus(final String state) {
        ses.execute(new Runnable() {
            public void run() {
                worker.setStatus(state);
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
        byte[] discoveryMessage = "discover".getBytes();

        synchronized void getStatus() {
            sendbuf[0] = 0;
            send(1);
        }

        void send(int len) {
            try {
                clientSocket.send(new DatagramPacket(sendbuf, len, remote, 1234));
            } catch (IOException e) {
                Log.e(TAG, e.toString());
            }
        }

        synchronized void setStatus(final String state) {
            sendbuf = state.getBytes(Charset.forName("ASCII"));
            Log.d(TAG, state);
            send(state.length());
        }

        @Override
        public void run() {
            byte[] buffer = new byte[1000];
            while(true) {
                DatagramPacket recv = new DatagramPacket(buffer, buffer.length);
                try {
                    clientSocket.receive(recv);
                    byte[] recvData = recv.getData();
                    String recvString = new String(recvData, recv.getOffset(), recv.getLength());
                    if (recvString.equals("discover")) {
                        remote = recv.getAddress();
                    } else if (recvString.startsWith("distance")) {
                        Log.d("DISTANCE", recvString);
                        final double distance = Double.parseDouble(recvString.split(":")[1]);
                        binder.publishEvent(new TransportEvent() {
                            @Override
                            public double distance() {
                                return distance;
                            }
                        });
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        public void discover() {
            try {
                InetAddress broadcast = getBroadcastAddress();
                DatagramPacket packet = new DatagramPacket(discoveryMessage, 0, discoveryMessage.length, broadcast, 1234);
                clientSocket.send(packet);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
