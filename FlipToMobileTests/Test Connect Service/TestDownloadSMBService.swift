//
//  TestDownloadSMBService.swift
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

class TestDownloadSMBService: QuickSpec {
    override func spec() {
        describe("Test download file") {
            
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
            
            beforeEach {
                let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                if let paths = try? FileManager.default.contentsOfDirectory(atPath: documentURL!.path) {
                    for path in paths {
                        let filePath = documentURL?.appendingPathComponent(path)
                        if FileManager.default.fileExists(atPath: filePath!.path) {
                            try? FileManager.default.removeItem(atPath: filePath!.path)
                        }
                    }
                }
            }
            
            afterEach {
                let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                if let paths = try? FileManager.default.contentsOfDirectory(atPath: documentURL!.path) {
                    for path in paths {
                        let filePath = documentURL?.appendingPathComponent(path)
                        if FileManager.default.fileExists(atPath: filePath!.path) {
                            try? FileManager.default.removeItem(atPath: filePath!.path)
                        }
                    }
                }
            }
    
            context("When download file from smb server") {
                it("Should download and save file success") {
                    var connectService: ConnectSMBService!
                    var downloadService: DownloadSMBService?
                    var smbClient: AMSMB2?
                    var listDownloadFile: [File] = []
                    connectService = ConnectSMBService()
                    connectService.connectToSMBServer(server: "smb://10.1.14.175", shareFolder: "sharedoc") { (result) in
                        switch result {
                        case.success(let client):
                            smbClient = client
                        default:
                            print("Connect smb fail")
                        }
                    }
                    expect(smbClient).toEventuallyNot(beNil())
                    if let client = smbClient {
                        downloadService = DownloadSMBService(smbClient: client)
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
                                }
                            default:
                                print("Cant get list file")
                            }
                        }
                        sleep(3)
                        if let download = downloadService {
                            let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(listDownloadFile.first?.name ?? "").path
                            var isDownloadFile = false
                            if FileManager.default.fileExists(atPath: filePath ?? "") {
                                isDownloadFile = true
                            }
                            expect(isDownloadFile).to(beFalse())
                            let downloadDelegate = DownloadDelegate()
                            download.downloadDelegate = downloadDelegate
                            download.downloadListFile(listFile: listDownloadFile)
                            expect(downloadDelegate.isCompleteDownload).toEventually(beTrue(), timeout: .seconds(10))
                            if FileManager.default.fileExists(atPath: filePath ?? "") {
                                isDownloadFile = true
                            }
                            expect(isDownloadFile).to(beTrue())
                        }
                    }
                }
            }
        }
    }
}
