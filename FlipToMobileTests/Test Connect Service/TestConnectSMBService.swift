//
//  TestConnectSMBService.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 29/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
import AMSMB2
@testable import To_Mobile

class TestSMBConnectService: QuickSpec {
    override func spec() {
        describe("Test SMB Connect Service") {
            var errorConnect: Error?
            var smbClient: AMSMB2?
            var service: ConnectSMBService?
            
            beforeEach {
                errorConnect = nil
                smbClient = nil
                service = ConnectSMBService()
            }
            
            context("When connect to SMB Server with invalid server address, share folder") {
                it("Should have error") {
                    let server = "server"
                    let shareFolder = "share"
                    expect(errorConnect).to(beNil())
                    expect(smbClient).to(beNil())
                    service?.connectToSMBServer(server: server, shareFolder: shareFolder) { (result) in
                        switch result {
                        case.failure(let error) :
                            errorConnect = error
                        case .success(let client):
                            smbClient = client
                        }
                    }
                    expect(errorConnect).toEventuallyNot(beNil(), timeout: .seconds(30))
                    expect(smbClient).toEventually(beNil(), timeout: .seconds(30))
                }
            }

            context("When connect SMB Server with correct server, correct share folder") {
                it("Should have no error") {
                    let server = "smb://10.1.14.175"
                    let shareFolder = "sharedoc"
                    expect(errorConnect).to(beNil())
                    expect(smbClient).to(beNil())
                    service?.connectToSMBServer(server: server, shareFolder: shareFolder) { (result) in
                        switch result {
                        case.failure(let error) :
                            errorConnect = error
                            print("error")
                        case .success(let client):
                            smbClient = client
                            print("success")
                        }
                    }
                    expect(errorConnect).toEventually(beNil(), timeout: .seconds(3))
                    expect(smbClient).toEventuallyNot(beNil(), timeout: .seconds(3))
                }
            }

            context("When connect SMB Server with correct server, wrong folder string") {
                it("Should have error") {
                    let server = "smb://10.1.14.175"
                    let shareFolder = "share"
                    expect(errorConnect).to(beNil())
                    expect(smbClient).to(beNil())
                    let service = ConnectSMBService()
                    service.connectToSMBServer(server: server, shareFolder: shareFolder) { (result) in
                        switch result {
                        case.failure(let error) :
                            errorConnect = error
                        case .success(let client):
                            smbClient = client
                        }
                    }
                    expect(errorConnect).toEventuallyNot(beNil(), timeout: .seconds(30))
                    expect(smbClient).toEventually(beNil(), timeout: .seconds(30))
                }
            }

            context("When connect SMB Server with wrong server, correct folder string") {
                it("Should have error") {
                    let server = "smb://10.12.14.176"
                    let shareFolder = "sharedoc"
                    expect(errorConnect).to(beNil())
                    expect(smbClient).to(beNil())
                    let service = ConnectSMBService()
                    service.connectToSMBServer(server: server, shareFolder: shareFolder) { (result) in
                        switch result {
                        case.failure(let error) :
                            errorConnect = error
                        case .success(let client):
                            smbClient = client
                        }
                    }
                    expect(errorConnect).toEventuallyNot(beNil(), timeout: .seconds(90))
                    expect(smbClient).toEventually(beNil(), timeout: .seconds(90))
                }
            }
            
            context("When connect SMB Server with wrong server, folder string") {
                it("Should have error") {
                    let server = "smb://10.12.14.175"
                    let shareFolder = "share"
                    expect(errorConnect).to(beNil())
                    expect(smbClient).to(beNil())
                    service?.connectToSMBServer(server: server, shareFolder: shareFolder) { (result) in
                        switch result {
                        case.failure(let error) :
                            errorConnect = error
                        case .success(let client):
                            smbClient = client
                        }
                    }
                    expect(errorConnect).toEventuallyNot(beNil(), timeout: .seconds(90))
                    expect(smbClient).toEventually(beNil(), timeout: .seconds(90))
                }
            }
        }
    }
}
