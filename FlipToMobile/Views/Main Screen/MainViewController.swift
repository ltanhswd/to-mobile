//
//  SelectConnectTypeViewController.swift
//  TestSMB
//
//  Created by iOS on 11/23/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var scanQRImage: UIImageView!
    @IBOutlet weak var connectManualImage: UIImageView!
    @IBOutlet weak var downloadedRollImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var scanQRView: UIView!
    @IBOutlet weak var connectManualView: UIView!
    @IBOutlet weak var downloadedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        scanQRView.layer.cornerRadius = 14
        connectManualView.layer.cornerRadius = 14
        downloadedView.layer.cornerRadius = 14
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func tapScanQR(_ sender: Any) {
        guard let autoVC = storyboard?.instantiateViewController(withIdentifier: ScanQRCodeViewController.name()) as? ScanQRCodeViewController else { return }
        autoVC.setService(connectService: ConnectSMBService(), wifiService: ConnectWifiService())
        navigationController?.pushViewController(autoVC, animated: true)
    }
    
    @IBAction func tapManually(_ sender: Any) {
        let manualVC = ManuallyConnectViewController(nibName: ManuallyConnectViewController.name(), bundle: nil)
        manualVC.setService(connectService: ConnectSMBService(), wifiService: ConnectWifiService())
        navigationController?.pushViewController(manualVC, animated: true)
    }
    
    @IBAction func tapDownloaded(_ sender: Any) {
        let downloadedVC = DownloadedViewController(nibName: DownloadedViewController.name(), bundle: nil)
        downloadedVC.setDocumentURL(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
        navigationController?.pushViewController(downloadedVC, animated: true)
    }
    
    @IBAction func tapAboutApp(_ sender: Any) {
        let aboutVC = AboutAppViewController(nibName: AboutAppViewController.name(), bundle: nil)
        navigationController?.pushViewController(aboutVC, animated: true)
    }
}
