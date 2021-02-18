//
//  GetWifiService.swift
//  FlipToMobile
//
//  Created by NgoQuangThinh on 12/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import NetworkExtension

class ConnectWifiService: ConnectWifiProtocol {
    func connectWifi(ssid: String, password: String, handler: @escaping (Result<Bool, Error>) -> Void) {
        NEHotspotConfigurationManager.shared.getConfiguredSSIDs { [weak self] listSSID in
            listSSID.forEach {
                NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: $0)}
        }
        let configuration = NEHotspotConfiguration.init(ssid: ssid, passphrase: password, isWEP: false)
        //configuration.joinOnce = true
        NEHotspotConfigurationManager.shared.apply(configuration) { [weak self] (error) in
            if let error = error {
                let nsError = error as NSError
                if nsError.domain == Constants.NEHotspotConfigurationErrorDomain {
                    if let configError = NEHotspotConfigurationError(rawValue: nsError.code) {
                        switch configError {
                        case .invalid, .invalidSSID, .invalidWEPPassphrase,
                             .invalidEAPSettings, .invalidHS20Settings, .invalidHS20DomainName, .userDenied, .pending, .systemConfiguration, .unknown, .joinOnceNotSupported, .applicationIsNotInForeground, .internal, .invalidSSIDPrefix, .invalidWPAPassphrase:
                            print(error)
                            handler(.failure(error))
                        case .alreadyAssociated :
                            handler(.success(true))
                        @unknown default:
                            print(error)
                            handler(.failure(error))
                        }
                    }
                } else {
                    print(error)
                    handler(.failure(error))
                }
            } else {
                handler(.success(true))
            }
        }
    }
    
    func getListWifi() -> [String] {
        var listWifi: [String] = []
        let queue = DispatchQueue(label: "getListWifi")
        NEHotspotHelper.register(queue: queue) { [weak self] (command) in
            switch command.commandType {
            case .filterScanList:
                let originalNetworklist = command.networkList ?? []
                for network in originalNetworklist {
                    print("network Name: \(network.ssid); strength: \(network.signalStrength)")
                    listWifi.append(network.ssid)
                }
            default:
                break
            }
        }
        return ["Wifi_1", "Wifi_2", "R&D_Testing", "Wifi_4", "Wifi_5", "Wifi_6", "Wifi_7", "Wifi_8"]
        //return listWifi
    }
}
