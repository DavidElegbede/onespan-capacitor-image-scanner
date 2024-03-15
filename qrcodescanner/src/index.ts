import { registerPlugin } from '@capacitor/core';

import type { QRCodeScannerPlugin } from './definitions';

const QRCodeScanner = registerPlugin<QRCodeScannerPlugin>('QRCodeScanner', {
  web: () => import('./web').then(m => new m.QRCodeScannerWeb()),
});

export * from './definitions';
export { QRCodeScanner };
