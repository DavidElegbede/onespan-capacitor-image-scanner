#import <UIKit/UIKit.h>

// Import all public headers in the umbrella header of the framework to avoid the missing submodule warning in bridging headers
#import <MSSImageScanner/QRCodeScannerSDKCodeType.h>
#import <MSSImageScanner/QRCodeScannerSDKConstants.h>
#import <MSSImageScanner/QRCodeScannerSDKScannerDelegate.h>
#import <MSSImageScanner/QRCodeScannerSDKErrorCodes.h>
#import <MSSImageScanner/QRCodeScannerSDKInfo.h>
#import <MSSImageScanner/QRCodeScannerSDKDecodingResultData.h>

//! Project version number for QRCodeScannerSDK.
FOUNDATION_EXPORT double QRCodeScannerSDKVersionNumber;

//! Project version string for QRCodeScannerSDK.
FOUNDATION_EXPORT const unsigned char QRCodeScannerSDKVersionString[];


NS_ASSUME_NONNULL_BEGIN

static const NSString * QRCODESCANNERSDK_VERSION = @"4.28.1";

/**
 * Provides methods for QR Code and Cronto Code scanning
 */
NS_REFINED_FOR_SWIFT
@interface QRCodeScannerSDK : NSObject

/**
 * Returns the QRCodeScanner viewController.
 * You should consider to use the method with a scanner overlay, as it provides better performance and user experience.
 *
 * @param delegate The delegate that implement ScannerDelegate protocol.
 * @param vibrate To enable / disable vibration when QRCode is detected
 * @param codeType the type of code to scan : CodeTypeQrCode or CodeTypeCrontoCode or both (CodeTypeQrCode | CodeTypeCrontoCode)
 * @param image Image for the cancel button. If null, no cancel button will be displayed.
 * @param error pointer to a NSError object. This object will be filled in case an error happened.
 * The error can contain one of the following error codes (see QRCodeScannerSDKErrorCodes.h):
 * <ul>
 *  <li>QRCodeScannerSDKErrorCodes_INTERNAL_ERROR if an internal error occurs.</li>
 *  <li>QRCodeScannerSDKErrorCodes_INPUT_PARAMETER_NULL if the input parameter is null.</li>
 *  <li>QRCodeScannerSDKErrorCodes_CAMERA_NOT_AVAILABLE if no camera is available to perform the scanning process.</li>
 *  <li>QRCodeScannerSDKErrorCodes_PERMISSION_DENIED if the permission to access to the camera is denied.</li>
 *  <li>QRCodeScannerSDKErrorCodes_INVALID_CODE_TYPE if the passed code type is invalid.</li>
 * </ul>
 *
 * @return A QRCodeScanner view controller.
 */
+ (UIViewController * _Nullable)getQRCodeScannerSDKViewControllerWithDelegate:(id<ScannerDelegate>)delegate
                                                                      vibrate:(BOOL)vibrate
                                                                     codeType:(CodeType)codeType
                                                                        image:(UIImage * _Nullable)image
                                                                        error:(NSError * _Nullable * _Nullable)error;

/**
 * Returns the QRCodeScanner viewController.
 *
 * @param delegate The delegate that implement ScannerDelegate protocol.
 * @param vibrate To enable / disable vibration when QRCode is detected
 * @param codeType the type of code to scan : CodeTypeQrCode or CodeTypeCrontoCode or both (CodeTypeQrCode | CodeTypeCrontoCode)
 * @param image Image for the cancel button. If null, no cancel button will be displayed.
 * @param scannerOverlay To enable / disable the scanner overlay.
 * @param scannerOverlayColor UIColor to define the overlay color. If nil the default color (0x99000000) is used.
 * @param error pointer to a NSError object. This object will be filled in case an error happened.
 * The error can contain one of the following error codes (see QRCodeScannerSDKErrorCodes.h):
 * <ul>
 *  <li>QRCodeScannerSDKErrorCodes_INTERNAL_ERROR if an internal error occurs.</li>
 *  <li>QRCodeScannerSDKErrorCodes_INPUT_PARAMETER_NULL if the input parameter is null.</li>
 *  <li>QRCodeScannerSDKErrorCodes_CAMERA_NOT_AVAILABLE if no camera is available to perform the scanning process.</li>
 *  <li>QRCodeScannerSDKErrorCodes_PERMISSION_DENIED if the permission to access to the camera is denied.</li>
 *  <li>QRCodeScannerSDKErrorCodes_INVALID_CODE_TYPE if the provided code type is invalid.</li>
 * </ul>
 * 
 * @return A QRCodeScanner view controller.
 */
+ (UIViewController * _Nullable)getQRCodeScannerSDKViewControllerWithDelegate:(id<ScannerDelegate>)delegate
                                                                      vibrate:(BOOL)vibrate
                                                                     codeType:(CodeType)codeType
                                                                        image:(UIImage * _Nullable)image
                                                               scannerOverlay:(BOOL)scannerOverlay
                                                          scannerOverlayColor:(UIColor * _Nullable)scannerOverlayColor
                                                                        error:(NSError * _Nullable * _Nullable)error;

/**
 * Decodes an image containing Cronto or QR code.
 * @param image Image to decode
 * @param codeType the type of code to scan : CodeTypeQrCode or CodeTypeCrontoCode or both (CodeTypeQrCode | CodeTypeCrontoCode)
 * @param error pointer to a NSError object. This object will be filled in case an error happened.
 * The error can contain one of the following error codes (see QRCodeScannerSDKErrorCodes.h):
 * <ul>
 *  <li>QRCodeScannerSDKErrorCodes_INVALID_CODE_TYPE if the provided code type is invalid.</li>
 *  <li>QRCodeScannerSDKErrorCodes_IMAGE_TOO_BIG if the provided image is too big to process. Maximum width and height of an image is 2048.</li>
 *  <li>QRCodeScannerSDKErrorCodes_INVALID_IMAGE if the provided image is invalid and cannot be decoded.</li>
 * </ul>
 *
 * @return A result data containing decoded code and its type. Nil if an error happened.
 *
 * @warning Maximum width and height of an image is 2048. Make sure the code is in the center of the image, is well focused and not too close, to avoid optical distortions.
 *
 * @warning The method processes the image and this could take some time to achieve, therefore it should be performed on another queue so that the main queue isn't blocked.
 */
+ (QRCodeScannerSDKDecodingResultData * _Nullable)decodeImage:(UIImage *)image
                                                     codeType:(CodeType)codeType
                                                        error:(NSError * _Nullable * _Nullable)error;

/**
 * Returns the current version of QRCodeScannerSDK
 */
+ (const NSString *)frameworkVersion;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

/*!
 * \mainpage Image Scanner SDK API - Programmer documentation
 * \brief Provides the entry points of the Image SDK framework API:
 * <ul>
 *  <li>Instantiate a scanner View Controller using QRCodeScannerSDK methods, giving chosen configuration options and a pointer to a class implementing ScannerDelegate.</li>
 *  <li>Delegate must be implemented according the ScannerDelegate protocol.</li>
 * </ul>
 * @OneSpanCopyright
 * @version 4.28.1
 */
