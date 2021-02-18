//
//  TestDownloadSMBService.swift
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

class TestDownloadScreenViewModel: QuickSpec {
    override func spec() {
        describe("Test download SMB Service") {
            var connectService: ConnectServiceProtocol?
            var smbClient: AMSMB2?
            var downloadScreenVM: DownloadScreenViewModel?
            var listDownloadFile:[ListFileDownloadModel]?
            
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
                   if server == "smb://10.1.14.175" && shareFolder == "sharedoc" {
                        handler(.success(client))
                    }
                }
            }
            
            beforeEach {
                connectService = MockSMBService()
                listDownloadFile = nil
                var listPdfFile = ListFileDownloadModel(headerTitle: "PDF File", items: [])
                var listOtherFile = ListFileDownloadModel(headerTitle: "Other File", items: [])
                for index in 1...10 {
                    let filePdf = File(name: "File_\(index).pdf", path: "File_\(index).pdf", type: nil, size: 1024, modified: Date(), created: Date())
                    listPdfFile.items.append(filePdf)
                    let fileOther = File(name: "File_\(index).iwb", path: "File_\(index).iwb", type: nil, size: 1024, modified: Date(), created: Date())
                    listOtherFile.items.append(fileOther)
                }
                listDownloadFile = [listPdfFile, listOtherFile]
            }
            
            context("When get list file from SMB Server") {
                it("Number of file should be equal or greater than 0") {
                    connectService?.connectToSMBServer(server: "smb://10.1.14.175", shareFolder: "sharedoc") { (result) in
                        switch result {
                        case .failure :
                            print("Connect SMB Fail")
                        case.success(let client) :
                            smbClient = client
                        }
                    }
                    expect(smbClient).toNot(beNil())
                    if let smbClient = smbClient {
                        let fileService = SMBFileService(smbClient: smbClient)
                        downloadScreenVM = DownloadScreenViewModel(fileService: fileService)
                        let disposeBag = DisposeBag()
                        var listFiles: [ListFileDownloadModel] = []
                        var numberPdfFiles = 0
                        expect(listFiles.count).to(equal(0))
                        downloadScreenVM?.listFileWithSection.subscribe(onNext: { (listFile) in
                            listFiles = listFile
                            if listFiles.count > 0 {
                                numberPdfFiles = listFiles[0].items.count
                            }
                        }).disposed(by: disposeBag)
                        
                        downloadScreenVM?.listFileWithSection.accept(listDownloadFile ?? [])
                        expect(listFiles.count).toEventually(beGreaterThan(0), timeout: .seconds(3))
                        expect(numberPdfFiles).toEventually(beGreaterThan(0), timeout: .seconds(3))
                        print(listFiles.count)
                    }
                }
            }
            
        }
    }
}
