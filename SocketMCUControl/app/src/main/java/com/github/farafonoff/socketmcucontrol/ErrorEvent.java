package com.github.farafonoff.socketmcucontrol;

/**
 * Created by Artem_Farafonov on 10/9/2017.
 */

public class ErrorEvent {
    public ErrorEvent(Throwable caught) {
        this.caught = caught;
    }

    Throwable caught;
}
