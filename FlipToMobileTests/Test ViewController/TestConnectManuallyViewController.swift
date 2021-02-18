//
//  TestConnectManuallyViewController.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 04/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxCocoa
import RxSwift
@testable import To_Mobile

class TestConnectManuallyViewController: QuickSpec {
    override func spec() {
        describe("Test Manual Connect View Controller") {
            
            class GetNoWifiNameService: ConnectWifiProtocol {
                func connectWifi(ssid: String, password: String, handler: @escaping (Result<Bool, Error>) -> Void) {
                    
                }
                
                func getListWifi() -> [String] {
                    let wifiList: [String] = []
                    return wifiList
                }
            }
            
            class GetWifiNameService: ConnectWifiProtocol {
                func connectWifi(ssid: String, password: String, handler: @escaping (Result<Bool, Error>) -> Void) {
                    
                }
                
                func getListWifi() -> [String] {
                    let wifiList = ["Wifi_1", "Wifi_2", "Wifi_3", "Wifi_4", "Wifi_5", "Wifi_6", "Wifi_7", "Wifi_8"]
                    return wifiList
                }
            }

            var manualVC: ManuallyConnectViewController!
            
            beforeEach {
                
            }
            
            context("When wifi name is not found") {
                it("Wifi name table view should have no row") {
                    manualVC = ManuallyConnectViewController()
                    let wifiService = GetNoWifiNameService()
                    let connectService = ConnectSMBService()
                    manualVC.setService(connectService: connectService, wifiService: wifiService)
                    let _ =  manualVC.view
                    let numberOfRow = manualVC.wifiTableView.numberOfRows(inSection: 0)
                    expect(numberOfRow) == 0
                }
            }
            
            context("When wifi name is found") {
                it("Table view wifi name should show correct data") {
                    manualVC = ManuallyConnectViewController()
                    let wifiService = GetWifiNameService()
                    let connectService = ConnectSMBService()
                    manualVC.setService(connectService: connectService, wifiService: wifiService)
                    let _ =  manualVC.view
                    let indexPath = IndexPath(row: 0, section: 0)
                    let cell = manualVC.wifiTableView.cellForRow(at: indexPath) as? ListWifiTableViewCell
                    expect(cell?.wifiName.text) == "Wifi_1"
                }
            }
        }
    }
}

