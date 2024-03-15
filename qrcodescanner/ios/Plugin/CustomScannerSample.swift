// Copyright ® 2023 OneSpan North America, Inc. All rights reserved. 

 
/////////////////////////////////////////////////////////////////////////////
//
//
// This file is example source code. It is provided for your information and
// assistance. See your licence agreement for details and the terms and
// conditions of the licence which governs the use of the source code. By using
// such source code you will be accepting these terms and conditions. If you do
// not wish to accept these terms and conditions, DO NOT OPEN THE FILE OR USE
// THE SOURCE CODE.
//
// Note that there is NO WARRANTY.
//
//////////////////////////////////////////////////////////////////////////////


import UIKit
import MSSImageScanner
import CoreMedia

protocol CustomScanningDelegate: AnyObject {
    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer)
    func didCancel()
    func didReceive(_ error: Error)
}

/// This sample class presents usage of custom scanner view and `decodeImage` SDK method
class CustomScannerSample: NSObject {
//    private weak var resultDelegate: ScanResultDelegate?
    private weak var scanner: CustomScannerViewController?

//    init(resultDelegate: ScanResultDelegate) {
//        self.resultDelegate = resultDelegate
//    }

    func scanCode(presentingVC: UIViewController) {
        let scannerViewController = CustomScannerViewController.instantiate(with: self)
        scannerViewController.modalPresentationStyle = .overFullScreen
        presentingVC.present(scannerViewController, animated: true, completion: nil)

        self.scanner = scannerViewController
    }

    // MARK: - Scanned Image Processing

    private func processBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let image = makeUIImage(from: sampleBuffer) else {
            return
        }

        decodeImage(image)
    }

    /// Used to convert `CMSampleBuffer` data from `AVFoundation` to `UIImage` object
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

    /// Actual `UIImage` decoding stage
    private func decodeImage(_ image: UIImage) {
        do {
            let output = try QRCodeScannerSDK.decodeImage(image, codeType: .all)
            DispatchQueue.main.async {
//                self.resultDelegate?.didScan(result: output.result, codeType: output.codeType)
                self.scanner?.dismiss(animated: true, completion: nil)
            }
        } catch ScannerError.invalidImage {
            // Code not decoded - try in next frame
        } catch let error {
//            resultDelegate?.didReceive(error)
        }
    }
}

// MARK: - CustomScanningDelegate
extension CustomScannerSample: CustomScanningDelegate {
    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer) {
        self.processBuffer(sampleBuffer)
    }

    func didCancel() {
//        resultDelegate?.didCancel()
    }

    func didReceive(_ error: Error) {
//        resultDelegate?.didReceive(error)
    }
}
