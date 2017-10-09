import { Component, OnInit } from '@angular/core';
import { TransportService, Contact } from '../transport/transport.service';

@Component({
  selector: 'app-contactlist',
  templateUrl: './contactlist.component.html',
  styleUrls: ['./contactlist.component.css']
})
export class ContactlistComponent implements OnInit {
  contacts: Contact[];
  myname: string = '';

  constructor(private transport: TransportService) { 
    this.myname = transport._anonymousContact.name;
    transport.contactLists.subscribe((contacts) => {
      this.contacts = contacts;
    })
  }

  ngOnInit() {
  }

  onSubmit() {
    console.log(this.myname);
    this.transport.changeName(this.myname);
  }
}
