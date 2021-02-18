//
//  GetWifiProtocol.swift
//  FlipToMobile
//
//  Created by NgoQuangThinh on 12/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation

protocol ConnectWifiProtocol {
    func getListWifi() -> [String]
    func connectWifi(ssid: String, password: String, handler: @escaping (Result<Bool, Error>) -> Void)
}
