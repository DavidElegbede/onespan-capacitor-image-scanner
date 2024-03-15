import Foundation
import Capacitor
import AVFoundation
import CoreMedia
import MSSImageScanner

@objc(QRCodeScannerPlugin)
public class QRCodeScannerPlugin: CAPPlugin, ScannerDelegate, CustomScanningDelegate {
    var scanCallback: CAPPluginCall?

    private weak var scanner: CustomScannerViewController?

    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let image = makeUIImage(from: sampleBuffer) else {
            return
        }
        decodeImage(image)
    }
    private func decodeImage(_ image: UIImage) {
        do {
            let output = try QRCodeScannerSDK.decodeImage(image, codeType: .all)
                DispatchQueue.main.async {
                    guard let bridge = self.bridge,
                          let viewController = bridge.viewController else {
                        return
                    }
                    viewController.dismiss(animated: true, completion: nil)
                    self.scanCallback?.resolve(["result": output.result, "codeType": output.codeType.rawValue] as [String: Any])
                    // Dismiss the scanner view controller
                   
                }
            } catch ScannerError.invalidImage {
            } catch let error {
                self.scanCallback?.reject("Failed to get QR code scanner view controller: \(error)")
            }
    }


    func didCancel() {
        self.scanCallback?.resolve(["result": "User cancelled scanning"] as [String: Any])
        
    }
    
    func didReceive(_ error: Error) {
        self.scanCallback?.reject("Received Error \(error)");
    }
    
    public func qrCodeScannerSDKController(_ controller: UIViewController, didScan result: String, codeType: MSSImageScanner.CodeType) {
        print("resultresult",result);
        print("codeType",codeType);
        self.scanCallback?.resolve(["result": result, "codeType": codeType.rawValue] as [String: Any])
        
//        self.scanCallback?.resolve(["result": result, "codeType": codeType])
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    public func qrCodeScannerSDKControllerDidCancel(_ controller: UIViewController) {
        controller.dismiss(animated: true, completion: nil)
        self.scanCallback?.resolve(["result": "User cancelled scanning"] as [String: Any])
    }
    
    public func qrCodeScannerSDKController(_ controller: UIViewController, didReceive error: MSSImageScanner.ScannerError) {
        self.scanCallback?.reject("Received Error \(error)");
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func scan(_ call: CAPPluginCall) {
        scanCallback = call
        // Retrieve the values from the plugin call
        guard let extra_vibrate = call.getString("extra_vibrate") else {
            return;
        }
        print("extra_vibrate",extra_vibrate);
        let extra_code_type = call.getString("extra_code_type")
        print("extra_code_type", extra_code_type);
        guard let extra_scanner_overlay = call.getString("extra_scanner_overlay") else { return}
        print("extra_scanner_overlay",extra_scanner_overlay);
        
    
        guard let colorHex = call.getString("extra_scanner_overlay_color") else {
            call.reject("Color not provided")
            return
        }

        // Convert hexadecimal color string to UIColor
        guard let color = UIColor(hexString: colorHex) else {
            call.reject("Invalid color format")
            return
        }

        
        // Get the presenting view controller (if available)
        guard let presentingVC = self.bridge?.viewController else {
            call.reject("Failed to get presenting view controller")
            return
        }

        DispatchQueue.main.async {
            // Check camera permission status
            let cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
            print("cameraPermissionStatus", cameraPermissionStatus)

            switch cameraPermissionStatus {
            case .authorized:
                self.presentScanner(with: presentingVC, vibrate: Bool(extra_vibrate) ?? true, overlay: Bool(extra_scanner_overlay) ?? true ,extra_scanner_overlay_color: color)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    if granted {
                        self?.presentScanner(with: presentingVC, vibrate: Bool(extra_vibrate) ?? true, overlay: Bool(extra_scanner_overlay) ?? true ,extra_scanner_overlay_color: color)
                    } else {
                        self?.callReject("Permission is required to access the camera")
                    }
                }
            case .denied, .restricted:
                self.callReject("Permission is required to access the camera")
            @unknown default:
                self.callReject("Permission is required to access the camera")
            }
        }
    }




    private func callReject(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.scanCallback?.reject(message)
        }
    }

    private func presentScanner(with presentingVC: UIViewController, vibrate: Bool, overlay: Bool , extra_scanner_overlay_color : UIColor?) {
        do {
            let scanner = try QRCodeScannerSDK.getQRCodeScannerSDKViewController(
                delegate: self,
                vibrate: vibrate,
                codeType: .all,
                image: UIImage(named: "QRScan_close"),
                scannerOverlay: overlay,
                scannerOverlayColor: extra_scanner_overlay_color)
            
            scanner.modalPresentationStyle = .fullScreen
            presentingVC.present(scanner, animated: true, completion: nil)
        } catch {
            callReject("Failed to get QR code scanner view controller: \(error.localizedDescription)")
        }
    }

    
    
    

        // MARK: - Image Processing Functions

        private func makeUIImage(from sampleBuffer: CMSampleBuffer) -> UIImage? {
            guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return nil
            }

            let ciImage = CIImage(cvPixelBuffer: cvBuffer)
            let context = CIContext(options: nil)

            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return nil
            }

            return UIImage(cgImage: cgImage)
        }


}

extension UIColor {
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
