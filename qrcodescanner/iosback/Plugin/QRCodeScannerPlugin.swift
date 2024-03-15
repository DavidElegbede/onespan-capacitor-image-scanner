import Foundation
import Capacitor
import AVFoundation
import CoreMedia
import MSSImageScanner

@objc(QRCodeScannerPlugin)
public class QRCodeScannerPlugin: CAPPlugin {
    
    var scanCallback: CAPPluginCall?
    
    @objc func scan(_ call: CAPPluginCall) {
        let scanner = try QRCodeScannerSDK.getQRCodeScannerSDKViewController(
                        delegate: self,
                        vibrate: true,
                        codeType: .all,
                        image: UIImage(named: "QRScan_close"),
                        scannerOverlay: true,
                        scannerOverlayColor: nil)
        scanCallback = call
        
        let cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraPermissionStatus {
        case .authorized:
            openCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.openCamera()
                    }
                } else {
                    call.reject("Permission is required to access the camera")
                }
            }
        case .denied, .restricted:
            call.reject("Permission is required to access the camera")
        @unknown default:
            call.reject("Permission is required to access the camera")
        }
    }
    
    private func openCamera() {
        print("this function called!")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let viewController =  self.bridge?.viewController;
            let systemCameraViewController = SystemCameraViewController()
            systemCameraViewController.delegate = self
             viewController?.present(systemCameraViewController, animated: true, completion: nil)
        }
    }
}

extension QRCodeScannerPlugin: SystemCameraViewControllerDelegate {
    func systemCameraViewControllerDidCancel(_ viewController: SystemCameraViewController) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.scanCallback?.resolve(["imageInfo": "RESULT_CANCELED"])
        }
    }
    
    func systemCameraViewController(_ viewController: SystemCameraViewController, didFinishScanningWithResult result: [String: Any]) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.scanCallback?.resolve(result)
        }
    }
}

protocol SystemCameraViewControllerDelegate: AnyObject {
    func systemCameraViewControllerDidCancel(_ viewController: SystemCameraViewController)
    func systemCameraViewController(_ viewController: SystemCameraViewController, didFinishScanningWithResult result: [String: Any])
}

class SystemCameraViewController: UIViewController {
    
    weak var delegate: SystemCameraViewControllerDelegate?
    var captureSession: AVCaptureSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get capture device.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let metaDataOutput = AVCaptureMetadataOutput()
            if (captureSession?.canAddOutput(metaDataOutput) ?? false) {
                captureSession?.addOutput(metaDataOutput)
                metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metaDataOutput.metadataObjectTypes = [.qr]
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = view.layer.bounds
                view.layer.addSublayer(previewLayer)
                
                captureSession?.startRunning()
            }
        } catch {
            print("Error initializing capture device input: \(error.localizedDescription)")
        }
    }
}

extension SystemCameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            print("No QR code detected.")
            return
        }
        
        delegate?.systemCameraViewController(self, didFinishScanningWithResult: ["qrCodeValue": stringValue])
    }
}

