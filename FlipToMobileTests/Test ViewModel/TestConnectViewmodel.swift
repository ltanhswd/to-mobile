//
//  TestConnectViewmodel.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 29/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

@testable import To_Mobile
import Foundation
import Quick
import Nimble
import RxSwift
import RxCocoa
import AMSMB2

class TestConnectViewModel: QuickSpec {
    override func spec() {
        describe("Test Connect View Model") {

            var connectSerivce: ConnectServiceProtocol?
            var wifiService: ConnectWifiProtocol?
            var viewModel: ConnectViewModel?
            let disposeBag = DisposeBag()
            
            class MockSMBService: ConnectServiceProtocol {
                
                enum connectError: Error {
                    case initError
                }
                
                func connectToSMBServer(server: String, shareFolder: String, handler: @escaping (Result<AMSMB2, Error>) -> Void) {
                    let credential = URLCredential(user: Constants.guestUser, password: "", persistence: URLCredential.Persistence.forSession)
                    guard let serverURL = URL(string: server), let client = AMSMB2(url: serverURL, credential: credential) else {
                            handler(.failure(connectError.initError))
                            return
                    }
                    
                    if server == "smb://10.12.14.175" && shareFolder == "share" {
                        handler(.failure((connectError.initError)))
                    } else if server == "smb://10.12.14.175" && shareFolder == "sharedoc" {
                        handler(.failure((connectError.initError)))
                    } else if server == "smb://10.1.14.175" && shareFolder == "share" {
                        handler(.failure((connectError.initError)))
                    }else if server == "smb://10.1.14.175" && shareFolder == "sharedoc" {
                        handler(.success(client))
                    }
                }
            }
            
            class MockWifiService: ConnectWifiProtocol {
                enum wifiError: Error {
                    case initError
                }
                
                func getListWifi() -> [String] {
                    let listWifi: [String] = []
                    return listWifi
                }
                
                func connectWifi(ssid: String, password: String, handler: @escaping (Result<Bool, Error>) -> Void) {
                    if ssid == "Invalid" {
                        handler(.failure(wifiError.initError))
                    } else if ssid  == "Correct" {
                        handler(.success(true))
                    }
                }
            }
            
            beforeEach {
                connectSerivce = MockSMBService()
                wifiService = MockWifiService()
                viewModel = ConnectViewModel(connectService: connectSerivce!, wifiService: wifiService!)
            }
            
            afterEach {
                connectSerivce = nil
                viewModel = nil
            }
            
            context("When init Connect View Model") {
                it("instance variable should not be nil") {
                    let connectSerivce = ConnectSMBService()
                    let viewModel = ConnectViewModel(connectService: connectSerivce)
                    let smbClient = viewModel.smbServiceClient
                    let wifiStatus = viewModel.connectWifiStatus
                    expect(smbClient).notTo(beNil())
                    expect(wifiStatus).notTo(beNil())
                }
            }
            
            context("When call function connectToSMBServer") {
                it("Should emit error when server address and share folder is wrong") {
                    var error: Error?
                    expect(error).to(beNil())
                    viewModel?.connectSMBError.subscribe(onNext: { connectError in
                        error = connectError
                    }).disposed(by: disposeBag)
                    viewModel?.connectToSMBServer(server: "server", shareFolder: "share")
                    expect(error).toNot(beNil())
                }
                
                it("Should emit error when server address is right and share folder is wrong") {
                    var error: Error?
                    expect(error).to(beNil())
                    viewModel?.connectSMBError.subscribe(onNext: { connectError in
                        error = connectError
                    }).disposed(by: disposeBag)
                    viewModel?.connectToSMBServer(server: "smb://10.1.14.175", shareFolder: "share")
                    expect(error).toNot(beNil())
                }
                
                it("Should emit error when server address is wrong and share folder is wrong") {
                    var error: Error?
                    expect(error).to(beNil())
                    viewModel?.connectSMBError.subscribe(onNext: { connectError in
                        error = connectError
                    }).disposed(by: disposeBag)
                    viewModel?.connectToSMBServer(server: "smb://10.12.14.175", shareFolder: "share")
                    expect(error).toNot(beNil())
                }
                
                it("Should emit new value when server address and share folder are right") {
                    var smbClient: AMSMB2?
                    expect(smbClient).to(beNil())
                    viewModel?.smbServiceClient.subscribe(onNext: { (client) in
                        smbClient = client
                    }).disposed(by: disposeBag)
                    viewModel?.connectToSMBServer(server: "smb://10.1.14.175", shareFolder: "sharedoc")
                    expect(smbClient).toNot(beNil())
                }
            }
            
            context("When connect Wifi") {
                it("Should have error when invalid ssid") {
                    var error: Error?
                    var isSuccess: Bool?
                    expect(error).to(beNil())
                    viewModel?.connectWifiError.subscribe(onNext: { (errorWifi) in
                        error = errorWifi
                    }).disposed(by: disposeBag)
                    viewModel?.connectWifiStatus.subscribe(onNext: { (status) in
                        isSuccess = status
                    }).disposed(by: disposeBag)
                    viewModel?.connectWifi(ssid: "Invalid", password: "12345678")
                    expect(error).toNot(beNil())
                    expect(isSuccess).to(beNil())
                }
                
                it("Should have error when correct ssid and password") {
                    var error: Error?
                    var isSuccess: Bool?
                    expect(error).to(beNil())
                    viewModel?.connectWifiError.subscribe(onNext: { (errorWifi) in
                        error = errorWifi
                    }).disposed(by: disposeBag)
                    viewModel?.connectWifiStatus.subscribe(onNext: { (status) in
                        isSuccess = status
                        expect(isSuccess).to(beTrue())
                    }).disposed(by: disposeBag)
                    viewModel?.connectWifi(ssid: "Correct", password: "12345678")
                    expect(error).to(beNil())
                }
            }
        }
    }
}
