#import <UIKit/UIKit.h>
#import <MSSImageScanner/QRCodeScannerSDKCodeType.h>

/**
 * Protocol definition to manage callback for result scanned, canceling and receive errors
 */
NS_ASSUME_NONNULL_BEGIN

NS_REFINED_FOR_SWIFT
@protocol ScannerDelegate

	/**
     * Protocol ScannerDelegate  method called when result is decoded
     * @param controller An object pointer to current QRCodeScannerSDKViewController sender
     * @param result The string decoded as NSString *
     * @param codeType The type of image scanned. Could be
     * <ul>
     *  <li>CodeTypeQrCode if a QR Code image has been scanned (see QRCodeScannerSDKCodeType.h).</li>
     *  <li>CodeTypeCrontoCode if a crontoSign image has been scanned (see QRCodeScannerSDKCodeType.h).</li>
     * </ul>
     */
    - (void)qrCodeScannerSDKController:(UIViewController *)controller didScan:(NSString *)result codeType:(CodeType)codeType;

	/**
     * Protocol ScannerDelegate  method called when the user touch on cancel button.
     * @param controller An object pointer to current QRCodeScannerSDKViewController sender
     */
	- (void)qrCodeScannerSDKControllerDidCancel:(UIViewController *)controller;
	
	/**
     * Protocol ScannerDelegate method called when error has occured
     * @param controller An object pointer to current QRCodeScannerSDKViewController sender
     * @param error pointer to a NSError object. This object will be filled in case an error happened.
     * The error can contain one of the following error codes (see QRCodeScannerSDKErrorCodes.h):
     * <ul>
     *  <li>QRCodeScannerSDKErrorCodes_INTERNAL_ERROR if an internal error occurs.</li>
     * </ul>
     */
	- (void)qrCodeScannerSDKController:(UIViewController *)controller didReceive:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
