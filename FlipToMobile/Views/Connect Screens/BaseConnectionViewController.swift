//
//  BaseViewController.swift
//  FlipToMobile
//
//  Created by NgoQuangThinh on 25/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BaseConnectionViewController: UIViewController {
    
    var connectingDialog: ConnectingDialogViewController?
    var connectViewModel: ConnectViewModel?
    var disposedBag = DisposeBag()
    var ssidName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showConnectingErrorDialog(title: String, message: String) {
        let alert = UIAlertController(title: title  , message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    func setObserver() {
        connectViewModel?.smbServiceClient.subscribe(onNext: { [weak self] (client) in
            DispatchQueue.main.async { [weak self] in
                let downloadScreen = DownloadScreenViewController(nibName: DownloadScreenViewController.name(), bundle: nil)
                let fileService = SMBFileService(smbClient: client)
                downloadScreen.setService(smbClient: client, fileService: fileService, folderPath: "", ssidName: self?.ssidName ?? "")
                self?.connectingDialog?.dismiss(animated: true, completion: {
                    self?.connectViewModel?.connectWifiError.onCompleted()
                    self?.connectViewModel?.connectSMBError.onCompleted()
                    self?.connectViewModel?.connectWifiStatus.onCompleted()
                    self?.connectViewModel?.smbServiceClient.onCompleted()
                    self?.navigationController?.pushViewController(downloadScreen, animated: true)
                })
            }
        }).disposed(by: disposedBag)
        
        connectViewModel?.connectWifiError.subscribe(onNext: { [weak self] (error) in
//            let nsError = error as NSError
//            if nsError.domain == Constants.wifiErrorDomain {
//                DispatchQueue.main.async {
//                    self?.connectingDialog?.dismiss(animated: true)
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self?.connectingDialog?.dismiss(animated: true, completion: {
//                        self?.showConnectingErrorDialog(title: "Connect Wifi Error", message: error.localizedDescription)
//                    })
//                }
//            }
            DispatchQueue.main.async {
                self?.connectingDialog?.dismiss(animated: true)
            }
        }).disposed(by: disposedBag)
    }
    
    func connectWifi(ssid: String, password: String) {
        if connectViewModel == nil {
            let connectService = ConnectSMBService()
            connectViewModel = ConnectViewModel(connectService: connectService)
            setObserver()
        }
        connectViewModel?.connectWifi(ssid: ssid, password: password)
    }
    
    func connectServer(serverIP: String, shareFolder: String?) {
        if let folder = shareFolder {
            connectViewModel?.connectToSMBServer(server: "smb://\(serverIP)", shareFolder: folder)
        } else {
            connectViewModel?.connectToSMBServer(server: "smb://\(serverIP)", shareFolder: "sharedoc")
        }
    }
}

//extension BaseConnectionViewController: CancelConnectionProtocol {
//    func cancelConnect() {
//        connectViewModel = nil
//    }
//}
