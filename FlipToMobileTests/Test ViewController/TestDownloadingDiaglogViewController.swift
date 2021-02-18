//
//  TestDownloadingDiaglogViewController.swift
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

class TestDownloadingDialogViewController: QuickSpec {
    override func spec() {
        describe("Test Downloading Dialog View Controller") {
            context("When load view controller") {
                it("Should load success") {
                    var connectService: ConnectSMBService!
                    var downloadService: DownloadSMBService!
                    var downloadingDialog: DownloadingDialogViewController!
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
                    expect(smbClient).toEventuallyNot(beNil(), timeout: .seconds(3))
                    if let client = smbClient {
                        downloadService = DownloadSMBService(smbClient: client)
                        downloadingDialog = DownloadingDialogViewController()
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
                        sleep(1)
                        downloadingDialog.totalFile = listDownloadFile.count
                        downloadingDialog.totalByte = 0
                        downloadingDialog.listFileDownload = listDownloadFile
                        downloadingDialog.downloadService = downloadService
                        let _ = downloadingDialog.view
                        downloadingDialog.beginAppearanceTransition(true, animated: false)
                        downloadingDialog.endAppearanceTransition()
                        downloadingDialog.viewDidAppear(false)
                        expect(downloadingDialog.totalFileLabel.text).to(equal("1"))
                    }
                }
            }
        }
    }
}
