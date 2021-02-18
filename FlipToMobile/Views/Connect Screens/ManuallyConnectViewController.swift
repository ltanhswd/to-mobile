//
//  ManuallyConnectViewController.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 14/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ManuallyConnectViewController: BaseConnectionViewController {

    @IBOutlet weak var wifiTableView: UITableView!
    
    private var wifiService: ConnectWifiProtocol?
    private var connectService: ConnectServiceProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectViewModel = ConnectViewModel(connectService: connectService ?? ConnectSMBService(), wifiService: wifiService ?? ConnectWifiService())
        setupLayout()
        setObserver()
    }
    
    func setService(connectService: ConnectServiceProtocol, wifiService: ConnectWifiProtocol) {
        self.connectService = connectService
        self.wifiService = wifiService
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupLayout() {
        self.title = Constants.connectManualScreenTitle
        wifiTableView.delegate = self
        wifiTableView.clipsToBounds = true
        wifiTableView.separatorStyle = .singleLine
        let footerView = UIView()
        footerView.backgroundColor = Constants.viewBackgroundColor
        wifiTableView.tableFooterView = footerView
    }
    
    override func setObserver() {
        super.setObserver()

        connectViewModel?.connectWifiStatus.subscribe(onNext: { [weak self] (status) in
            if status {
                self?.connectServer(serverIP: Constants.serverIPTest, shareFolder: nil)
            }
        }).disposed(by: disposedBag)
        
        connectViewModel?.connectSMBError.subscribe(onNext: { [weak self] (error) in
            DispatchQueue.main.async { [weak self] in
                self?.connectingDialog?.dismiss(animated: true, completion: {
                    self?.showConnectingErrorDialog(title: "Connect File Server Error", message: error.localizedDescription)
                })
            }
        }).disposed(by: disposedBag)
        
        connectViewModel?.listWifiName.asObservable().bind(to: wifiTableView.rx.items) {[weak self] (tableView, row, wifiName) -> UITableViewCell in
            let cell = Bundle.main.loadNibNamed(ListWifiTableViewCell.name(), owner: self, options: nil)?.first as? ListWifiTableViewCell
            cell?.wifiName.text = wifiName
            return cell ?? UITableViewCell()
        }.disposed(by: disposedBag)
        
        wifiTableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.showAskPasswordDiaglog(ssid: (self?.connectViewModel?.listWifiName.value[indexPath.row] ?? ""))
            self?.wifiTableView.deselectRow(at: indexPath, animated: false)
        }).disposed(by: disposedBag)
    }
    
    private func showAskPasswordDiaglog(ssid: String) {
        let dialog = UIAlertController(title: "Enter password", message: "Enter password for \"\(ssid)\"", preferredStyle: .alert)
        
        dialog.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let connectAction = UIAlertAction(title: "Connect", style: .cancel) { [weak self] _ in
            if let password = dialog.textFields?[0].text {
                if password != "" {
                    self?.connectingDialog = ConnectingDialogViewController(nibName: ConnectingDialogViewController.name(), bundle: nil)
                    self?.connectingDialog?.modalPresentationStyle = .overFullScreen
                    self?.connectingDialog?.modalTransitionStyle = .crossDissolve
                    self?.connectingDialog?.cancelConnectDelegate = self
                    self?.present(self?.connectingDialog ?? UIViewController(), animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.connectWifi(ssid: ssid, password: password)
                    }
                }
            }
        }
        connectAction.isEnabled = false
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: dialog.textFields?[0], queue: .main) { _ in
            if dialog.textFields?[0].text != "" {
                connectAction.isEnabled = true
            } else {
                connectAction.isEnabled = false
            }
        }
        
        let cancelAction = UIAlertAction(title: Constants.cancelButtonTile, style: .default) { _ in
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: dialog.textFields?[0])
        }
        dialog.addAction(connectAction)
        dialog.addAction(cancelAction)
        present(dialog, animated: true)
    }
}

extension ManuallyConnectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ManuallyConnectViewController: CancelConnectionProtocol {
    func cancelConnect() {
        connectViewModel = nil
    }
}
