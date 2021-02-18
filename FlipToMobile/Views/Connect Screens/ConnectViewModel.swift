//
//  MainViewModel.swift
//  TestSMB
//
//  Created by iOS on 11/19/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import UIKit
import AMSMB2
import NetworkExtension
import RxCocoa
import RxSwift
import SystemConfiguration.CaptiveNetwork
import SystemConfiguration
import Reachability
import Network

class ConnectViewModel {
    
    private var connectService: ConnectServiceProtocol
    private var wifiService: ConnectWifiProtocol?
    private var noWifiConnected = true
    
    var connectWifiStatus = PublishSubject<Bool>()
    var smbServiceClient = PublishSubject<AMSMB2>()
    var connectSMBError = PublishSubject<Error>()
    var connectWifiError = PublishSubject<Error>()
    var listWifiName = BehaviorRelay<[String]>(value: [])
    var connectionInfo = BehaviorRelay<ConnectionInfo?>(value: nil)
    
    init(connectService: ConnectServiceProtocol) {
        self.connectService = connectService
    }
    
    init(connectService: ConnectServiceProtocol, wifiService: ConnectWifiProtocol) {
        self.connectService = connectService
        self.wifiService = wifiService
        getListWifi()
    }
    
    func connectToSMBServer(server:String, shareFolder: String) {
        connectService.connectToSMBServer(server: server, shareFolder: shareFolder, handler: { [weak self] (result) in
            switch result {
            case .failure(let error) :
                print(error)
                self?.connectSMBError.onNext(error)
            case .success(let smbClient) :
                self?.smbServiceClient.onNext(smbClient)
            }
        })
    }
    
    func connectWifi(ssid: String, password: String) {
        wifiService?.connectWifi(ssid: ssid, password: password, handler: { [weak self] (result) in
            switch result {
            case .failure(let error) :
                self?.connectWifiError.onNext(error)
            case.success(let status):
                if status {
                    self?.checkConnectedWifi()
                }
            }
        })
    }
    
    private func getCurrentSSID() -> [String] {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return []
        }
        return interfaceNames.compactMap { name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else {
                return nil
            }
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            return ssid
        }
    }
    
    private func checkConnectedWifi() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                if !path.isExpensive  { // connected to wifi
                    print("Wifi connected")
                    self?.connectWifiStatus.onNext(true)
                    monitor.cancel()
                }
            } else if path.status == .unsatisfied { 
                if self?.noWifiConnected ?? true {
                    self?.noWifiConnected = false
                } else {
                    let error = NSError(domain: Constants.wifiErrorDomain, code: 001, userInfo: [ NSLocalizedDescriptionKey: "Unabale Connect"])
                    self?.connectWifiError.onNext(error)
                    self?.noWifiConnected = true
                    monitor.cancel()
                }
                print("Unsatisfied")
            } else if path.status == .requiresConnection {
                print("Require Connection")
            }
        }
        monitor.start(queue: queue)
    }
    
    private func getListWifi() {
        let listWifi = wifiService?.getListWifi()
        listWifiName.accept(listWifi ?? [])
    }
}
