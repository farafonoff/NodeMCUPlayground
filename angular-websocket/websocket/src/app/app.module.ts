import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { AppComponent } from './app.component';
import { ContactlistComponent } from './contactlist/contactlist.component';
import { ChatwindowComponent } from './chatwindow/chatwindow.component';
import { TransportService } from './transport/transport.service';

@NgModule({
  declarations: [
    AppComponent,
    ContactlistComponent,
    ChatwindowComponent
  ],
  imports: [
    BrowserModule,
    FormsModule
  ],
  providers: [TransportService],
  bootstrap: [AppComponent]
})
export class AppModule { }
