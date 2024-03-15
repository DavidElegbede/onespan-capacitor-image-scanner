export interface QRCodeScannerPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  scan(options: {value: string}): Promise<any>;

  pluginPermissionMethod(): Promise<any>;
  opencamera(): Promise<any>;

}
