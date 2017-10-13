package com.github.farafonoff.socketmcucontrol;

import android.os.Binder;
import android.os.IBinder;

import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Artem_Farafonov on 10/9/2017.
 */

public class TransportBinder extends Binder {
    public TransportBinder(SocketService parentInstance) {
        this.parentInstance = parentInstance;
    }

    private SocketService parentInstance;
    private List<TransportEventListener> listeners = new ArrayList<>();
    void setStatus(String state) {
        parentInstance.setStatus(state);
    }

    void attachListener(TransportEventListener listener) {
        listeners.add(listener);
    }

    void detachListener(TransportEventListener listener) {
        listeners.remove(listener);
    }
}
