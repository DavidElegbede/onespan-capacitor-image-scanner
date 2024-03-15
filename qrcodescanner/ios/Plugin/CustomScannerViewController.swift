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
import AVFoundation

enum CustomScannerError: LocalizedError {
    case inputSetupFail
    case captureSessionSetupFail

    var errorDescription: String? {
        switch self {
        case .inputSetupFail:
            return "Input device setup failed"
        case .captureSessionSetupFail:
            return "Capture session setup failed"
        }
    }
}

class CustomScannerViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private weak var preview: UIView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var topGradientView: UIView!
    @IBOutlet private weak var bottomGradientView: UIView!

    // MARK: - Variables

    private weak var delegate: CustomScanningDelegate?

    private var topGradientLayer: CAGradientLayer?
    private var bottomGradientLayer: CAGradientLayer?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - Initialization

    final class func instantiate(with delegate: CustomScanningDelegate) -> CustomScannerViewController {
        let storyboard = UIStoryboard(name: "CustomScanner", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! CustomScannerViewController
        viewController.delegate = delegate
        return viewController
    }

    // MARK: - Interactions

    @IBAction private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
        delegate?.didCancel()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScanner()
        setupGradients()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startScanner()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopScanner()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        topGradientLayer?.frame = topGradientView.bounds
        bottomGradientLayer?.frame = bottomGradientView.bounds
    }

    // MARK: - Scanner setup

    private func setupScanner() {
        guard let input = makeDeviceInput() else {
            delegate?.didReceive(CustomScannerError.inputSetupFail)
            return
        }

        let output = makeVideoOutput()

        guard let captureSession = makeCaptureSession(from: input, to: output) else {
            delegate?.didReceive(CustomScannerError.captureSessionSetupFail)
            return
        }
        setupPreview(for: captureSession)
    }

    private func makeDeviceInput() -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return nil
        }

        do {
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            device.unlockForConfiguration()
        } catch {
            return nil
        }

        return try? AVCaptureDeviceInput(device: device)
    }

    private func makeVideoOutput() -> AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)
        ]

        let queue = DispatchQueue(label: "scanner_queue")
        output.setSampleBufferDelegate(self, queue: queue)

        return output
    }

    private func makeCaptureSession(from input: AVCaptureDeviceInput, to output: AVCaptureVideoDataOutput) -> AVCaptureSession? {
        let session = AVCaptureSession()
        session.beginConfiguration()

        if !session.canSetSessionPreset(.hd1280x720) {
            return nil
        }

        if !session.canAddInput(input) {
            return nil
        }

        // This 1280x720 resolution is used to fit into the SDK required size and make buffer conversion faster
        session.sessionPreset = .hd1280x720
        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()
        captureSession = session
        
        return captureSession
    }

    private func setupPreview(for session: AVCaptureSession) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.view.layer.frame
        preview.layer.addSublayer(layer)
        previewLayer = layer
        
        self.changeCameraOrientation()
    }

    private func startScanner() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }

    private func stopScanner() {
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()

        captureSession = nil
        previewLayer = nil
    }

    // MARK: - View setup
    private func setupGradients() {
        let topGradient = CAGradientLayer()
        topGradient.colors = [UIColor(white: 0.0, alpha: 0.8).cgColor, UIColor.clear.cgColor]
        topGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        topGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        topGradientView.layer.insertSublayer(topGradient, at: 0)
        topGradientLayer = topGradient

        let bottomGradient = CAGradientLayer()
        bottomGradient.colors = [UIColor.clear.cgColor, UIColor(white: 0.0, alpha: 0.8).cgColor]
        bottomGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        bottomGradientView.layer.insertSublayer(bottomGradient, at: 0)
        bottomGradientLayer = bottomGradient
    }
}

// MARK: - Device Rotation
extension CustomScannerViewController {
    
    var currentInterfaceOrientation: UIInterfaceOrientation? {
        get {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                return nil
            }
            return orientation
        }
    }
    
    func changeCameraOrientation() {
        previewLayer?.frame = self.view.bounds
        if (self.previewLayer?.connection?.isVideoOrientationSupported != nil) {
            let previewLayerConnection = self.previewLayer?.connection
            
            switch self.currentInterfaceOrientation {
                case .landscapeRight:
                    previewLayerConnection?.videoOrientation = .landscapeRight
                case .landscapeLeft:
                    previewLayerConnection?.videoOrientation = .landscapeLeft
                case .portraitUpsideDown:
                    previewLayerConnection?.videoOrientation = .portraitUpsideDown
                case .portrait:
                    fallthrough
                default:
                    previewLayerConnection?.videoOrientation = .portrait
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            // Update camera orientation on each device rotation
            self.changeCameraOrientation()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CustomScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
        delegate?.didCaptureBuffer(sampleBuffer)
    }
}
