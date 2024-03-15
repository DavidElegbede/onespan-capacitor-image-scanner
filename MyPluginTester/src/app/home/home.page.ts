import { Component } from '@angular/core';
import {QRCodeScanner} from '../../../../qrcodescanner';
interface ScanOptions {
    extra_vibrate: string;
    extra_code_type: string;
    extra_scanner_overlay: string;
}

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {
  extra_vibrate: boolean = true;
  extra_code_type: number = 3;
  extra_scanner_overlay: boolean = true;
  extra_scanner_overlay_color: string  = "#000000";

constructor() {}

async launchSystemCamera() {
  const options = {
    extra_vibrate: this.extra_vibrate,
    extra_code_type: this.extra_code_type,
    extra_scanner_overlay: this.extra_scanner_overlay,
    extra_scanner_overlay_color: this.convertUIColorToHex(this.extra_scanner_overlay_color)
  };

  try {
    const res = await QRCodeScanner.scan(options);
    alert(JSON.stringify(res));
  } catch (error) {
    alert(JSON.stringify(error));
  }
}
convertUIColorToHex(color: string): string {
  // Implement your conversion logic here
  return color;
}


}