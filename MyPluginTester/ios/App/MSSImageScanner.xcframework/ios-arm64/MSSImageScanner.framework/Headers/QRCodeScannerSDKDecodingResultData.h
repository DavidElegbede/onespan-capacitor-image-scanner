//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) since 1999. VASCO DATA SECURITY
//  All rights reserved. http://www.vasco.com
//
//////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <MSSImageScanner/QRCodeScannerSDKCodeType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a result of image decoding.
 * Contains decoded result and code type.
 */
NS_REFINED_FOR_SWIFT
@interface QRCodeScannerSDKDecodingResultData : NSObject

/**
 * Returns decoded string result
 */
@property(nonatomic, readonly, copy) NSString *result;

/**
 * Returns decoded code type.
 *
 * Possible values are: `CodeTypeQrCode` or `CodeTypeCrontoCode`
 */
@property(nonatomic, readonly) CodeType codeType;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
