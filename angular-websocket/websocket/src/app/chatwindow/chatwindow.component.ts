import { Component, OnInit } from '@angular/core';
import { TransportService, Message, Contact } from '../transport/transport.service';

@Component({
  selector: 'app-chatwindow',
  templateUrl: './chatwindow.component.html',
  styleUrls: ['./chatwindow.component.css']
})
export class ChatwindowComponent implements OnInit {
  messages: Message[] = [];  
  msgtext: string = '';

  constructor(private transport: TransportService) { 
    transport.message.subscribe((message) => {
      this.messages.push(message);
    })
  }

  ngOnInit() {
  }

  onSubmit() {
    console.log(this.msgtext);
    this.transport.sendMessage(this.msgtext);
  }

}
