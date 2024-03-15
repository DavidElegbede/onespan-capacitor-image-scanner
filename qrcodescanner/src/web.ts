import { WebPlugin } from '@capacitor/core';

import type { QRCodeScannerPlugin } from './definitions';

export class QRCodeScannerWeb extends WebPlugin implements QRCodeScannerPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
  // async scan() {
  //   console.log('scanscanscanscanscan');
  // } 
  async scan(options: { value: string }): Promise<{ value: string }> {
    console.log("optionsoptions",options);
    return options;
}

  async pluginPermissionMethod(): Promise<void>{
    alert("plugin permission method");
     return
  }
  async opencamera(): Promise<void>{
    alert("plugin permission method");
     return
  }
}
