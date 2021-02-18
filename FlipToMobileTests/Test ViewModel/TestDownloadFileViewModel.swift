//
//  TestDownloadFileViewModel.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 07/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
import AMSMB2
@testable import To_Mobile

class TestDownloadFileViewModel: QuickSpec {
    override func spec() {
        describe("Test Download File ViewModel") {
            class DownloadDelegate: DownloadingProtocol {
                var isCompleteDownload = false
                func updateByteDownloadedNumber(downloadedByte: Int64) {
                }
                
                func updateFileDownloadedNumber() {
                    isCompleteDownload = true
                }
                
                func handleError(error: Error) {
                }
            }
            
            var connectService: ConnectSMBService?
            var downloadService: DownloadSMBService?
            var downloadVM: DownloadFileViewModel?
            var smbClient: AMSMB2?
            beforeEach {
                connectService = ConnectSMBService()
                smbClient = nil
                downloadService = nil
                downloadVM = nil
            }
            
            context("When start download") {
                it("Should start download and set delegate success") {
                    var listDownloadFile: [File] = []
                    connectService?.connectToSMBServer(server: "smb://10.1.14.175", shareFolder: "sharedoc") { (result) in
                        switch result {
                        case.success(let client):
                            smbClient = client
                        default:
                            print("Connect smb fail")
                        }
                    }
                    expect(smbClient).toEventuallyNot(beNil(), timeout: .seconds(3))
                    if let client = smbClient {
                        downloadService = DownloadSMBService(smbClient: client)
                        downloadVM = DownloadFileViewModel(downloadService: downloadService!)
                        let downloadDelegate = DownloadDelegate()
                        client.contentsOfDirectory(atPath: "") { (result) in
                            switch result {
                            case.success(let listItem) :
                                if let item = listItem.first {
                                    let name = item[.nameKey] as? String
                                    let path = item[.pathKey] as? String
                                    let type = item[.fileResourceTypeKey] as? URLFileResourceType
                                    let size = item[.fileSizeKey] as? Int64
                                    let modified = item[.contentModificationDateKey] as? Date
                                    let created = item[.creationDateKey] as? Date
                                    let file = File(name: name, path: path, type: type, size: size, modified: modified, created: created)
                                    listDownloadFile.append(file)
                                    expect(listDownloadFile.count).to(beGreaterThan(0))
                                    expect(downloadDelegate.isCompleteDownload).to(beFalse())
                                    downloadVM?.setDownloadDelegate(delegate: downloadDelegate)
                                    downloadVM?.startDownloadFileList(listFile: listDownloadFile)
                                }
                            default:
                                print("Cant get list file")
                            }
                        }
                        expect(downloadDelegate.isCompleteDownload).toEventually(beTrue(), timeout: .seconds(10))
                    }
                }
            }
        }
    }
}
