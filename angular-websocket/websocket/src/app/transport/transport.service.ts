import { Injectable, Output, EventEmitter, Input } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';
import { ReplaySubject } from 'rxjs/ReplaySubject';

export interface Contact {
  id: string;
  name: string;
}

export interface Message {
  id: string;
  from: Contact;
  content: string;
}

@Injectable()
export class TransportService {
  _anonymousContact: Contact = {name: "Anonymous", id: '_'};
  myName: Subject<string> = new BehaviorSubject(this._anonymousContact.name);
  @Output() contactLists: Subject<Contact[]>;
  @Output() message: Subject<Message>;
  socket :WebSocket;
  systemContact: Contact = {name: 'System', id: 'S'};
  msgid: number = 0;
  connected: BehaviorSubject<boolean>;

  changeName(name: string) {
    this.myName.next(name);
  }

  sendMessage(msg: string) {
    this.socket.send(JSON.stringify({type: 'message', content: msg}));
  }

  createSocket() {
    this.socket = new WebSocket('ws://epruizhw0298.moscow.epam.com:1337');
    this.socket.onopen = ev => {
      this.message.next({from: this.systemContact, content: 'Connected!', id: this.nextLocalId()});
      this.myName.subscribe(name => {
        this.socket.send(JSON.stringify({type: 'register', name: name}));
      })
      this.connected.next(true);
    }
    this.socket.onmessage = ev => {
      let data = JSON.parse(ev.data);
      console.log(data);
      switch(data.type) {
        case 'contactlist': {
          this.contactLists.next(data.payload);
          break;
        }
        case 'message': {
          this.message.next(data.payload);
        }
      }
    };
    this.socket.onclose = ev => {
      if (this.connected.value) {
        this.message.next({from: this.systemContact, content: 'Disconnected. Trying to reconnect', id: this.nextLocalId()});
      }
      this.connected.next(false);
      console.log('disconnect.. reconnecting');
      setTimeout(this.createSocket.bind(this), 100);
    }
  }

  constructor() { 
    this.contactLists = new BehaviorSubject([this._anonymousContact]);
    this.connected = new BehaviorSubject(false);
    this.message = new ReplaySubject(50);
    this.message.next({from: this.systemContact, content: 'Welcome!', id: this.nextLocalId()});
    this.createSocket();
  }

  nextLocalId(): string {
    return '_'+this.msgid;
  }
}
