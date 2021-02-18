//
//  TestDownloadScreenViewController.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 06/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
import AMSMB2
import RxSwift
import RxCocoa
@testable import To_Mobile

class TestDownloadScreenViewController: QuickSpec {
    override func spec() {
        describe("Test download Screen View Controller") {
            
            class MockFileService: FileServiceProtocol {
                func listFileAtPath(path: String, handler: @escaping (Result<[[URLResourceKey : Any]], Error>) -> Void) {
                    var listDataFile: [[URLResourceKey:Any]] = []
                    for index in 1...10 {
                        let data: [URLResourceKey:Any] = [.nameKey : "File_Name\(index).txt",
                                                          .pathKey : "File_Name\(index).txt",
                                                          .fileResourceTypeKey: NSString(string: ""),
                                                          .fileSizeKey: 1024,
                                                          .contentModificationDateKey: Date(),
                                                          .creationDateKey: Date()]
                        listDataFile.append(data)
                    }
                    handler(.success(listDataFile))
                }
            }
            
            class MockConnectService: ConnectServiceProtocol {
                enum connectError: Error {
                    case initError
                }
                
                func connectToSMBServer(server: String, shareFolder: String, handler: @escaping (Result<AMSMB2, Error>) -> Void) {
                    let credential = URLCredential(user: Constants.guestUser, password: "", persistence: URLCredential.Persistence.forSession)
                     guard let serverURL = URL(string: server), let client = AMSMB2(url: serverURL, credential: credential) else {
                             handler(.failure(connectError.initError))
                             return
                     }
                    handler(.success(client))
                }
            }
            
            var connectService: ConnectServiceProtocol!
            var smbClient: AMSMB2?
            var downloadVC: DownloadScreenViewController!
            
            context("When get list file from SMB Server") {
                it("Number of file should be equal or greater than 0") {
                    connectService = MockConnectService()
                    connectService.connectToSMBServer(server: "smb://10.1.14.175", shareFolder: "sharedoc") { (result) in
                        switch result {
                        case .failure :
                            print("Connect SMB Fail")
                        case.success(let client) :
                            smbClient = client
                        }
                    }
                    expect(smbClient).toNot(beNil())
                    if let smbClient = smbClient {
                        let fileService = MockFileService()
                        downloadVC = DownloadScreenViewController()
                        downloadVC.setService(smbClient: smbClient, fileService: fileService, folderPath: "")
                        let _ = downloadVC.view
                        let indexPath = IndexPath(row: 0, section: 0)
                        let cell = downloadVC.listFileTableView.cellForRow(at: indexPath) as? FileDownloadTableViewCell
                        //expect(cell?.fileName.text).toNot(beNil())
                    }
                }
            }
            
        }
    }
}
