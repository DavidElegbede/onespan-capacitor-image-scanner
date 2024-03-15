//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) since 1999. VASCO DATA SECURITY
//  All rights reserved. http://www.vasco.com
//
//////////////////////////////////////////////////////////////////////////////

#ifndef QRCodeScannerSDKCodeType_h
#define QRCodeScannerSDKCodeType_h

typedef NS_OPTIONS(NSInteger, CodeType) {
    /// Indicates QR code type
    CodeTypeQrCode = 1,
    
    /// Indicates Cronto code type
    CodeTypeCrontoCode = 2
} NS_REFINED_FOR_SWIFT;

#endif /* QRCodeScannerSDKCodeType_h */
