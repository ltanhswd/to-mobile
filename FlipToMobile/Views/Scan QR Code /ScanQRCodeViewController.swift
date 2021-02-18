//
//  ConnectAutoViewController.swift
//  TestSMB
//
//  Created by iOS on 11/23/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift

class ScanQRCodeViewController: BaseConnectionViewController {

    private var videoLayer = AVCaptureVideoPreviewLayer()
    private let captureSession = AVCaptureSession()
    private var connnectionInfo: ConnectionInfo?
    private var invalidQR: Bool = false
    private var wifiService: ConnectWifiProtocol?
    private var connectService: ConnectServiceProtocol?
    
    @IBOutlet weak var scanningView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectViewModel = ConnectViewModel(connectService: connectService ?? ConnectSMBService(), wifiService: wifiService ?? ConnectWifiService())
        setObserver()
        setupCaptureSession()
    }
    
    func setService(connectService: ConnectServiceProtocol, wifiService: ConnectWifiProtocol) {
        self.connectService = connectService
        self.wifiService = wifiService
    }
    
    override func viewDidLayoutSubviews() {
        setupLayout()
        videoLayer.frame = scanningView.layer.bounds
        videoLayer.cornerRadius = 14
        mainView.layer.cornerRadius = 14
        scanningView.layer.cornerRadius = 14
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func setObserver(){
        super.setObserver()
        connectViewModel?.connectWifiStatus.subscribe(onNext: {[weak self] (status) in
            if status {
                self?.connectServer(serverIP: self?.connnectionInfo?.keyIP ?? "", shareFolder: self?.connnectionInfo?.keyFolder ?? "")
            }
        }).disposed(by: disposedBag)
        
        connectViewModel?.connectSMBError.subscribe(onNext: { [weak self] (error) in
            DispatchQueue.main.async { [weak self] in
                self?.connectingDialog?.dismiss(animated: true, completion: {
                    self?.showConnectFileServerErrorDialog(title: "Connect File Server Error", message: error.localizedDescription)
                })
            }
        }).disposed(by: disposedBag)
    }
    
    private func showConnectFileServerErrorDialog(title: String, message: String) {
        let alert = UIAlertController(title: title  , message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.okButtonTitle, style: .default) { [weak self] _ in
            DispatchQueue.main.async {
                self?.captureSession.startRunning()
            }
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func setupCaptureSession() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        }
        catch let error  {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let ok = UIAlertAction(title: Constants.okButtonTitle, style: .default) { [weak self ](_) in
                self?.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoLayer.frame = scanningView.layer.bounds
        scanningView.layer.addSublayer(videoLayer)
        captureSession.startRunning()
        videoLayer.layoutIfNeeded()
    }
    
    private func showInvalidQRDialog(title: String, message: String) {
        let alert = UIAlertController(title: title  , message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if (self?.invalidQR)! {
                self?.captureSession.startRunning()
                self?.invalidQR = false
            }
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupLayout(){
        self.title =  Constants.scanQRSreenTitle
        mainView.layer.cornerRadius = 14
        mainView.layer.borderColor = UIColor.lightGray.cgColor
        mainView.layer.borderWidth = 0.5
    }
    
    private func decodeQR(stringValue: String) {
        guard let jsonData = stringValue.data(using: .utf8) else {
            showInvalidQRDialog(title: Constants.invalidQRCodeAlertTitle, message: Constants.invalidQRCode)
            invalidQR = true
            return
        }
        do {
            connnectionInfo = try JSONDecoder().decode(ConnectionInfo.self, from: jsonData)
            connectWifi(ssid: connnectionInfo?.keySSID ?? "", password: connnectionInfo?.keySSIDPassword ?? "")
            connectingDialog = ConnectingDialogViewController(nibName: ConnectingDialogViewController.name(), bundle: nil)
            connectingDialog?.modalPresentationStyle = .overFullScreen
            connectingDialog?.modalTransitionStyle = .crossDissolve
            connectingDialog?.cancelConnectDelegate = self
            ssidName = connnectionInfo?.keySSID
            present(connectingDialog ?? UIViewController(), animated: true, completion: nil)
        } catch {
            showInvalidQRDialog(title: Constants.invalidQRCodeAlertTitle, message: Constants.invalidQRCode)
            invalidQR = true
            return
        }
    }
}

extension ScanQRCodeViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            decodeQR(stringValue: stringValue)
        }
    }
}

extension ScanQRCodeViewController: CancelConnectionProtocol {
    func cancelConnect() {
        connectViewModel = nil
        captureSession.startRunning()
    }
}
